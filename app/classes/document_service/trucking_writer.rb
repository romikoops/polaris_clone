# frozen_string_literal: true

module DocumentService
  class TruckingWriter # rubocop:disable Metrics/ClassLength
    include AwsConfig
    include WritingTool
    attr_reader :options, :tenant, :hub, :target_load_type, :filename, :directory, :header_values,
                :workbook, :unfiltered_results, :carriage_reducer, :results_by_truck_type, :dir_fees,
                :zone_sheet, :fees_sheet, :header_format, :pages, :zones, :identifier

    def initialize(options) # rubocop:disable Metrics/MethodLength
      @options = options
      @tenant = tenant_finder(options[:tenant_id])
      @hub = Hub.find(options[:hub_id])
      @target_load_type = options[:load_type]
      @filename = _filename
      @directory = "tmp/#{@filename}"
      @workbook = create_workbook(@directory)
      @unfiltered_results = Trucking::Trucking.find_by_hub_id(
        hub_id: options[:hub_id],
        options: {
          group_id: options[:group_id],
          filters: {
            load_type: options[:load_type]
          },
          paginate: false
        }
      ).uniq.map(&:as_index_result)
      @carriage_reducer = {}
      @results_by_truck_type = {}
      @dir_fees = {}
      @header_format = @workbook.add_format
      @header_format.set_bold
      @zone_sheet = add_sheet('Zones')
      @fees_sheet = add_sheet('Fees')
      @pages = {}
      @zones = Hash.new { |h, k| h[k] = [] }
      @identifier = @unfiltered_results.first.except('truckingPricing', 'countryCode').keys.first
    end

    def perform
      if unfiltered_results.present?
        prep_results
        write_zone_to_sheet
        write_fees_to_sheet
        write_rates_to_sheet
      end
      workbook.close
      write_to_aws(directory, tenant, filename, 'schedules_sheet') if unfiltered_results.present?
    end

    private

    def prep_results # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      page_groupings = unfiltered_results.group_by do |ufr|
        [
          ufr.dig('truckingPricing', 'truck_type'),
          ufr.dig('truckingPricing', 'cargo_class'),
          ufr.dig('truckingPricing', 'load_type'),
          ufr.dig('truckingPricing', 'direction')
        ].join('_')
      end

      page_groupings.values.each do |page_values|
        grouped_results = page_values.group_by { |ufr| ufr['truckingPricing']['parent_id'] }
        grouped_results.values.each do |values|
          trucking = values.first['truckingPricing']
          next if trucking['rates'].empty?
          meta = _meta(values.first)
          identifiers = values.map do |v|
            if trucking['identifier_modifier'] == 'locode'
              v[identifier].split(' - ').first
            elsif identifier == 'city' && v[identifier].include?(' - ') && trucking['identifier_modifier'] != 'locode'
              v[identifier].split(' - ')
            else
              v[identifier]
            end
          end
          zone_identifiers = if %w(zipCode distance).include?(identifier)
                               consecutive_arrays(identifiers)
                             else
                               identifiers
                             end
          zone_key = zone_identifiers.first
          update_pages(meta, values.first, zone_key)
          update_dir_fees(meta, values.first)
          zone_identifiers.each do |ident|
          
            zone_obj = if ident.is_a?(Array)
              { idents: ident.first, sub_ident: ident.last, country_code: values.first['countryCode'] }
            else
              { idents: ident, country_code: values.first['countryCode'] }
            end
            zones[zone_key] << zone_obj
          end
        end
      end
    end

    def add_sheet(sheet_name)
      workbook.add_worksheet(sheet_name)
    end

    def _filename
      "#{hub.name}_#{target_load_type}_trucking_#{formated_date}.xlsx"
    end

    def _identifier
      ident = ''
      if unfiltered_results.first&.dig(['distance'])
        ident = 'distance'
      elsif unfiltered_results.first&.dig(['zipCode'])
        ident = 'zipCode'
      elsif unfiltered_results.first&.dig(['city'])
        ident = 'city'
      end
      ident
    end

    def _meta(ufr) # rubocop:disable Metrics/AbcSize
      {
        city: hub.nexus.name,
        currency: ufr['truckingPricing']['rates'].first[1][0]['rate']['currency'],
        load_meterage_ratio: ufr['truckingPricing']['load_meterage']['ratio'],
        load_meterage_limit: ufr['truckingPricing']['load_meterage']['height_limit'],
        load_meterage_area: ufr['truckingPricing']['load_meterage']['area_limit'],
        cbm_ratio: ufr['truckingPricing']['cbm_ratio'],
        scale: ufr['truckingPricing']['modifier'],
        rate_basis: ufr['truckingPricing']['rates'].first[1][0]['rate']['rate_basis'],
        base: ufr['truckingPricing']['rates'].first[1][0]['rate']['base'] || 1,
        truck_type: ufr['truckingPricing']['truck_type'],
        load_type: ufr['truckingPricing']['load_type'],
        cargo_class: ufr['truckingPricing']['cargo_class'],
        direction: ufr['truckingPricing']['carriage'] == 'pre' ? 'export' : 'import',
        courier: Trucking::Courier.find(ufr['truckingPricing']['courier_id'])&.name
      }
    end

    def write_zone_to_sheet
      header_values = ['ZONE', identifier_to_write.upcase, 'RANGE', 'COUNTRY_CODE']
      header_values.each_with_index { |hv, i| zone_sheet.write(0, i, hv, header_format) }
      zone_row = 1
      zones.values.each_with_index do |zone_array, zone|
        zone_array.each do |zone_data|
          write_zone_data(zone_row, zone, zone_data)
          zone_row += 1
        end
      end
    end

    def identifier_to_write
      if unfiltered_results.first['truckingPricing']['identifier_modifier']
        "#{identifier}_#{unfiltered_results.first['truckingPricing']['identifier_modifier']}"
      else
        identifier
      end
    end

    def write_zone_data(zone_row, zone, zone_data) # rubocop:disable Metrics/AbcSize
      zone_sheet.write(zone_row, 0, zone)
      if zone_data[:idents].include?(' - ')
        start_num, end_num = zone_data[:idents].split(' - ')
        if identifier_to_write.include?('return')
          zone_1 = start_num.to_f.positive? ? ((start_num.to_f * 2) - 1).to_i : 0
          zone_sheet.write(zone_row, 2, "#{zone_1} - #{(end_num.to_f * 2)}")
        else
          zone_sheet.write(zone_row, 2, "#{start_num} - #{end_num}")
        end
      else
        zone_sheet.write(zone_row, 1, zone_data[:idents])
      end
      zone_sheet.write(zone_row, 3, zone_data[:country_code])
    end

    def fee_header_values
      %w(FEE MOT FEE_CODE TRUCK_TYPE DIRECTION CURRENCY RATE_BASIS TON CBM KG
         ITEM SHIPMENT BILL CONTAINER MINIMUM WM PERCENTAGE)
    end

    def update_pages(meta, ufr, zone)
      page_key = "#{meta[:truck_type]}_#{meta[:cargo_class]}_#{meta[:load_type]}_#{meta[:direction]}"
      unless pages[page_key]
        pages[page_key] = {
          meta: meta,
          pricings: {}
        }
      end
      pages[page_key][:pricings][zone.to_s] = ufr
    end

    def update_dir_fees(meta, ufr)
      dir_fees[meta[:direction]] = {} unless dir_fees[meta[:direction]]

      unless dir_fees[meta[:direction]][meta[:truck_type]]
        dir_fees[meta[:direction]][meta[:truck_type]] = ufr['truckingPricing']['fees']
      end
    end

    def update_zones(ufr)
      return unless zones.include?(idents: ufr[identifier], country_code: ufr['countryCode'])

      zones.push(idents: ufr[identifier], country_code: ufr['countryCode'])
    end

    def write_fees_to_sheet # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      row = 1
      fee_header_values.each_with_index { |hv, i| fees_sheet.write(0, i, hv, header_format) }
      dir_fees.deep_symbolize_keys!
      dir_fees.each do |carriage_dir, truck_type_and_fees| # rubocop:disable Metrics/BlockLength
        truck_type_and_fees.each do |truck_type, fees| # rubocop:disable Metrics/BlockLength
          fees.each do |key, fee| # rubocop:disable Metrics/BlockLength
            fees_sheet.write(row, 0, fee[:name])
            fees_sheet.write(row, 1, hub.hub_type)
            fees_sheet.write(row, 2, key)
            fees_sheet.write(row, 3, truck_type)
            fees_sheet.write(row, 4, carriage_dir)
            fees_sheet.write(row, 5, fee[:currency])
            fees_sheet.write(row, 6, fee[:rate_basis])
            case fee[:rate_basis]
            when 'PER_CONTAINER'
              fees_sheet.write(row, 13, fee[:value])
            when 'PER_ITEM'
              fees_sheet.write(row, 10, fee[:value])
            when 'PER_BILL'
              fees_sheet.write(row, 12, fee[:value])
            when 'PER_SHIPMENT'
              fees_sheet.write(row, 11, fee[:value])
            when 'PER_CBM_TON'
              fees_sheet.write(row, 7, fee[:ton])
              fees_sheet.write(row, 8, fee[:cbm])
              fees_sheet.write(row, 14, fee[:min])
            when 'PER_CBM_KG'
              fees_sheet.write(row, 9, fee[:kg])
              fees_sheet.write(row, 8, fee[:cbm])
              fees_sheet.write(row, 14, fee[:min])
            when 'PER_WM'
              fees_sheet.write(row, 15, fee[:value])
            when 'PERCENTAGE'
              fees_sheet.write(row, 16, fee[:value])
            end
            row += 1
          end
        end
      end
    end

    def write_rates_to_sheet # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      pages.values.each_with_index do |page, i| # rubocop:disable Metrics/BlockLength
        rates_sheet = workbook.add_worksheet(i.to_s)
        rates_sheet.write(3, 0, 'ZONE')
        rates_sheet.write(3, 1, 'MIN')
        rates_sheet.write(4, 0, 'MIN')
        minimums = {}
        row = 5
        x = 2
        meta_x = 0
        page[:meta].each do |key, value|
          rates_sheet.write(0, meta_x, key.upcase)
          rates_sheet.write(1, meta_x, value)
          meta_x += 1
        end

        page[:pricings].values.first['truckingPricing']['rates'].each do |key, rates_array|
          rates_array.each do |rate|
            next unless rate

            rates_sheet.write(2, x, key.downcase)
            rates_sheet.write(3, x, "#{rate["min_#{key}"]} - #{rate["max_#{key}"]}")
            x += 1
          end
        end
        page[:pricings].values.each_with_index do |result, pi|
          rates_sheet.write(row, 0, pi)
          rates_sheet.write(row, 1, result['truckingPricing']['rates'].first[1][0]['min_value'])
          minimums[pi] = result['truckingPricing']['rates'].first[1][0]['min_value']
          x = 2
          result['truckingPricing']['rates'].each do |_key, rates_array|
            rates_array.each do |rate|
              next unless rate

              if rate['min_value']
                rates_sheet.write(row, 1, rate['min_value'].round(2))
              else
                rates_sheet.write(row, 1, 0)
              end
              rates_sheet.write(row, x, rate['rate']['value'].round(2))
              x += 1
            end
          end
          row += 1
        end
      end
    end

    def consecutive_arrays(ary)
      ary.sort.slice_when { |x, y| (x.to_i + 1) != y.to_i }.map do |c_ary|
        if c_ary.length == 1
          "#{c_ary.first} - #{c_ary.first}"
        else
          "#{c_ary.first} - #{c_ary.last}"
        end
      end
    end
  end
end
