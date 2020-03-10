# frozen_string_literal: true

module DocumentService
  class TruckingWriter
    include AwsConfig
    include WritingTool
    attr_reader :options, :tenant, :hub, :target_load_type, :filename, :directory, :header_values,
                :workbook, :trucking_pricings,:results_by_truck_type, :dir_fees,
                :zone_sheet, :fees_sheet, :header_format, :pages, :zones

    def initialize(options)
      @options = options
      @tenant = tenant_finder(options[:tenant_id])
      @hub = Hub.find(options[:hub_id])
      @target_load_type = options[:load_type]
      @filename = _filename
      @directory = "tmp/#{@filename}"
      @workbook = create_workbook(@directory)
      @trucking_pricings = Trucking::Trucking.where(
        hub_id: options[:hub_id],
        group_id: options[:group_id],
        load_type: options[:load_type]
      )
      @results_by_truck_type = {}
      @dir_fees = {}
      @header_format = @workbook.add_format
      @header_format.set_bold
      @zone_sheet = add_sheet('Zones')
      @fees_sheet = add_sheet('Fees')
      @pages = {}
      @zones = Hash.new { |h, k| h[k] = [] }
    end

    def perform
      if trucking_pricings.present?
        prep_results
        write_zone_to_sheet
        write_fees_to_sheet
        write_rates_to_sheet
      end
      workbook.close
      write_to_aws(directory, tenant, filename, 'schedules_sheet') if trucking_pricings.present?
    end

    def load_trucking_locations(pricings)
      query = trucking_pricings.where(pricings.first.slice(:carriage, :truck_type, :cargo_class, :load_type))
      locations = Trucking::Location.where(id: pricings.pluck(:location_id)).order(:city_name)
      separated_locations = locations.slice_when do |a, b|
        query.find_by(location_id: a.id)&.parent_id != query.find_by(location_id: b.id)&.parent_id
      end

      separated_locations.each do |loc_arr|
        parent_id = query.find_by(location_id: loc_arr.first.id)&.parent_id
        values = loc_arr.map { |loc| loc.slice(:city_name, :country_code) }
        result = case identifier
                 when 'location_id' && identifier_modifier != 'postal_code'
                   values
                 else
                   consecutive_arrays(values)
                  end

        zones[parent_id] |= result
      end
    end

    def prep_results
      page_groupings = trucking_pricings.group_by do |trucking_pricing|
        [
          trucking_pricing.truck_type,
          trucking_pricing.cargo_class,
          trucking_pricing.load_type,
          trucking_pricing.carriage
        ]
      end

      page_groupings.values.each do |page_values|
        grouped_results = page_values.group_by(&:parent_id)
        load_trucking_locations(page_values)
        grouped_results.each do |parent_id, values|
          trucking = values.first
          next if trucking.rates.empty? || trucking.rates.values.flatten.all?(&:nil?)

          meta = build_meta(trucking)
          update_pages(meta, trucking, parent_id)
          update_dir_fees(meta, trucking)
        end
      end
    end

    def add_sheet(sheet_name)
      workbook.add_worksheet(sheet_name)
    end

    def _filename
      "#{hub.name}_#{target_load_type}_trucking_#{formated_date}.xlsx"
    end

    def build_meta(trucking_pricing)
      rate = ::Trucking::TruckingPricingDecorator.new(trucking_pricing)
      {
        city: hub.nexus.name,
        currency: rate.currency,
        load_meterage_ratio: trucking_pricing.load_meterage['ratio'],
        load_meterage_limit: trucking_pricing.load_meterage['height_limit'],
        load_meterage_area: trucking_pricing.load_meterage['area_limit'],
        cbm_ratio: trucking_pricing.cbm_ratio,
        scale: trucking_pricing.modifier,
        rate_basis: rate.rate_basis,
        base: rate.base || 1,
        truck_type: trucking_pricing.truck_type,
        load_type: trucking_pricing.load_type,
        cargo_class: trucking_pricing.cargo_class,
        direction: trucking_pricing.carriage == 'pre' ? 'export' : 'import',
        courier: Trucking::Courier.find(trucking_pricing['courier_id'])&.name
      }
    end

    def write_zone_to_sheet
      header_values = ['ZONE', *identifiers_to_write, 'COUNTRY_CODE']
      header_values.each_with_index { |hv, i| zone_sheet.write(0, i, hv, header_format) }
      zone_row = 1
      zones.values.each_with_index do |zone_array, zone|
        zone_array.each do |zone_data|
          write_zone_data(zone_row, zone, zone_data)
          zone_row += 1
        end
      end
    end

    def identifiers_to_write
      if identifier == 'location_id' && identifier_modifier == 'postal_code'
        [identifier_modifier.upcase, 'RANGE']
      elsif identifier == 'location_id' && [nil, 'f'].include?(identifier_modifier)
        %w(CITY PROVINCE)
      elsif identifier == 'distance' && ![nil, 'f'].include?(identifier_modifier)
        ["#{identifier}_#{identifier_modifier}".upcase, 'RANGE']
      else
        [identifier.upcase, 'RANGE']
      end
    end

    def write_zone_data(zone_row, zone, zone_data)
      zone_sheet.write(zone_row, 0, zone)

      if zone_data[:city_name].include?('-') && identifier == 'location_id' && identifier_modifier != 'postal_code'
        city, province = zone_data[:city_name].split('-').map(&:strip)
        zone_sheet.write(zone_row, 1, city)
        zone_sheet.write(zone_row, 2, province)
      elsif zone_data[:city_name].include?('-') && (identifier != 'location_id' || identifier_modifier == 'postal_code')
        zone_sheet.write(zone_row, 2, zone_data[:city_name])
      else
        zone_sheet.write(zone_row, 1, zone_data[:city_name])
      end
      zone_sheet.write(zone_row, 3, zone_data[:country_code])
    end

    def fee_header_values
      %w(FEE MOT FEE_CODE TRUCK_TYPE DIRECTION CURRENCY RATE_BASIS TON CBM KG
         ITEM SHIPMENT BILL CONTAINER MINIMUM WM PERCENTAGE)
    end

    def update_pages(meta, trucking_pricing, zone)
      page_key = "#{meta[:truck_type]}_#{meta[:cargo_class]}_#{meta[:load_type]}_#{meta[:direction]}"
      unless pages[page_key]
        pages[page_key] = {
          meta: meta,
          pricings: {}
        }
      end
      pages[page_key][:pricings][zone.to_s] = trucking_pricing
    end

    def update_dir_fees(meta, trucking_pricing)
      dir_fees[meta[:direction]] = {} unless dir_fees[meta[:direction]]
      unless dir_fees[meta[:direction]][meta[:truck_type]]
        dir_fees[meta[:direction]][meta[:truck_type]] = trucking_pricing['fees']
      end
    end

    def update_zones(trucking_pricing)
      return unless zones.include?(idents: trucking_pricing[identifier], country_code: trucking_pricing['countryCode'])

      zones.push(idents: trucking_pricing[identifier], country_code: trucking_pricing['countryCode'])
    end

    def write_fees_to_sheet
      row = 1
      fee_header_values.each_with_index { |hv, i| fees_sheet.write(0, i, hv, header_format) }
      dir_fees.deep_symbolize_keys!
      dir_fees.each do |carriage_dir, truck_type_and_fees|
        truck_type_and_fees.each do |truck_type, fees|
          fees.each do |key, fee|
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

    def write_rates_to_sheet
      pages.values.each_with_index do |page, i|
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

        page[:pricings].values.first['rates'].each do |key, rates_array|
          rates_array.each do |rate|
            next unless rate

            rates_sheet.write(2, x, key.downcase)
            rates_sheet.write(3, x, "#{rate["min_#{key}"]} - #{rate["max_#{key}"]}")
            x += 1
          end
        end
        page[:pricings].values.each_with_index do |result, pi|
          rates_sheet.write(row, 0, pi)
          rates_sheet.write(row, 1, result['rates'].first[1][0]['min_value'])
          minimums[pi] = result['rates'].first[1][0]['min_value']
          x = 2
          result['rates'].each do |_key, rates_array|
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

    def extract_number_array(array: ,alpha: nil, numeric: nil)
      if alpha.present? && numeric.present?
        array.map do |s|
          {
            city_name: s[:city_name].gsub(alpha, ''),
            country_code: s[:country_code]
          }
        end
      else
        array
      end
    end

    def consecutive_arrays(list_of_postal_codes)
      alpha_groups = list_of_postal_codes.group_by { |s| { alpha: s[:city_name].tr('^A-Z', ''), country: s[:country_code] } }
      alpha_groups.flat_map do |alpha_and_country, array|
        numeric = array.all? { |s| s[:city_name].tr('^0-9', '').present? }
        next list_of_postal_codes if alpha_and_country[:alpha].present? && numeric.blank?

        num_array = extract_number_array(array: array ,alpha: alpha_and_country[:alpha], numeric: numeric)

        city_name = [
          "#{alpha_and_country[:alpha]}#{num_array.first[:city_name]}",
          "#{alpha_and_country[:alpha]}#{num_array.last[:city_name]}"
        ].join(' - ')

        {
          city_name: city_name,
          country_code: num_array.first[:country_code]
        }
      end
    end

    private

    def identifier
      location = trucking_pricings.find(&:location)&.location
      @identifier ||=   if location&.zipcode.present?
                          'zipcode'
                        elsif location&.distance.present?
                          'distance'
                        elsif location&.location_id.present?
                          'location_id'
                        else
                          nil
                        end
    end

    def identifier_modifier
      @identifier_modifier ||=  unless trucking_pricings.first.identifier_modifier == 'f'
                                  trucking_pricings.first.identifier_modifier
                                end
    end


  end
end
