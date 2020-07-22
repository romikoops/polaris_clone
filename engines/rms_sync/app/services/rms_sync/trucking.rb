# frozen_string_literal: true

module RmsSync
  class Trucking < RmsSync::Base
    FEE_HEADERS = %w(FEE MOT FEE_CODE TRUCK_TYPE DIRECTION CURRENCY RATE_BASIS TON CBM KG
         ITEM SHIPMENT BILL CONTAINER MINIMUM WM PERCENTAGE).freeze
    def initialize(organization_id:, group_id: nil)
      @books = Hash.new { |h, k| h[k] = {} }
      @zones = Hash.new { |h, k| h[k] = [] }
      @group_id = group_id
      @pages = {}
      @dir_fees = {}
      super(organization_id: organization_id, sheet_type: :trucking)
    end

    def perform
      prepare_purge
      sync_data
      purge
    end

    def sync_data
      hubs.each do |hub|
        %w(cargo_item container).each do |load_type|
          @hub = hub
          @load_type = load_type
          next unless get_data

          @identifier = data.first.except('truckingPricing', 'countryCode').keys.first
          @identifier_modifier = data.first.dig('truckingPricing', 'identifier_modifier')
          create_book
          prep_results
          write_zones_to_sheet
          write_fees_to_sheet
          write_rates_to_sheet
        end
      end
      RmsData::Cell.import(@cells)
    end

    def get_data
      @data = ::Trucking::Trucking.find_by_hub_id(
        hub_id: hub.id,
        options: {
          group_id: group_id,
          filters: {
            load_type: load_type
          },
          paginate: false
        }
      ).uniq.map(&:as_index_result)
    end

    def hubs
      @hubs = ::Legacy::Hub.where(organization_id: @organization.id)
    end

    def create_book
      books[hub.id][load_type] = RmsData::Book.find_or_create_by(
        organization: @organization,
        sheet_type: :trucking,
        target: hub,
        book_type: load_type.to_sym
      )
    end

    def create_sheet_zone_sheet
      @zone_sheet = books[hub.id][load_type].sheets.create(organization_id: @organization.id, sheet_index: 0)
      zone_headers.each_with_index do |head, i|
        write_cell(zone_sheet, 0, i, head)
      end
    end

    def write_zones_to_sheet
      create_sheet_zone_sheet
      zone_row = 1
      zones.values.each_with_index do |zone_array, zone|
        zone_array.uniq.each do |zone_data|
          write_zone_data(zone_row, zone, zone_data)
          zone_row += 1
        end
      end
    end

    def write_zone_data(zone_row, zone, zone_data)
      write_cell(zone_sheet, zone_row, 0, zone)
      if zone_data[:idents].include?(' - ')
        start_num, end_num = zone_data[:idents].split(' - ')
        if identifier_to_write.include?('return')
          zone_1 = start_num.to_f.positive? ? ((start_num.to_f * 2) - 1).to_i : 0
          write_cell(zone_sheet, zone_row, 2, "#{zone_1} - #{(end_num.to_f * 2)}")
        else
          write_cell(zone_sheet, zone_row, 2, "#{start_num} - #{end_num}")
        end
      else
        write_cell(zone_sheet, zone_row, 1, zone_data[:idents])
      end
      write_cell(zone_sheet, zone_row, 3, zone_data[:country_code])
    end

    def zone_headers
      ident_header = identifier_to_write
      mod_header = ident_header == 'CITY' ? 'PROVINCE' : 'RANGE'
      ['ZONE', ident_header, mod_header, 'COUNTRY_CODE']
    end

    def identifier_to_write
      if @identifier_modifier == 'POSTAL_CODE'
        @identifier_modifier.to_s.upcase
      elsif @identifier_modifier
        "#{identifier}_#{@identifier_modifier}".upcase
      else
        identifier.upcase
      end
    end

    def update_pages(meta, trucking_result, zone)
      page_key = "#{meta[:truck_type]}_#{meta[:cargo_class]}_#{meta[:load_type]}_#{meta[:direction]}"
      unless pages[page_key]
        pages[page_key] = {
          meta: meta,
          pricings: {}
        }
      end
      pages[page_key][:pricings][zone.to_s] = trucking_result
    end

    def update_dir_fees(meta, trucking_result)
      dir_fees[meta[:direction]] = {} unless dir_fees[meta[:direction]]

      unless dir_fees[meta[:direction]][meta[:truck_type]]
        dir_fees[meta[:direction]][meta[:truck_type]] = trucking_result['truckingPricing']['fees']
      end

      dir_fees.deep_symbolize_keys!
    end

    def write_fees_to_sheet # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      @fees_sheet = @books[hub.id][load_type].sheets.create(organization_id: @organization.id, sheet_index: 1)
      row = 1
      FEE_HEADERS.each_with_index { |hv, i| write_cell(fees_sheet, 0, i, hv) }
      dir_fees.each do |carriage_dir, truck_type_and_fees| # rubocop:disable Metrics/BlockLength
        truck_type_and_fees.each do |truck_type, fees| # rubocop:disable Metrics/BlockLength
          fees.each do |key, fee| # rubocop:disable Metrics/BlockLength
            write_cell(fees_sheet, row, 0, fee[:name])
            write_cell(fees_sheet, row, 1, hub.hub_type)
            write_cell(fees_sheet, row, 2, key)
            write_cell(fees_sheet, row, 3, truck_type)
            write_cell(fees_sheet, row, 4, carriage_dir)
            write_cell(fees_sheet, row, 5, fee[:currency])
            write_cell(fees_sheet, row, 6, fee[:rate_basis])
            case fee[:rate_basis]
            when 'PER_CONTAINER'
              write_cell(fees_sheet, row, 13, fee[:value])
            when 'PER_ITEM'
              write_cell(fees_sheet, row, 10, fee[:value])
            when 'PER_BILL'
              write_cell(fees_sheet, row, 12, fee[:value])
            when 'PER_SHIPMENT'
              write_cell(fees_sheet, row, 11, fee[:value])
            when 'PER_CBM_TON'
              write_cell(fees_sheet, row, 7, fee[:ton])
              write_cell(fees_sheet, row, 8, fee[:cbm])
              write_cell(fees_sheet, row, 14, fee[:min])
            when 'PER_CBM_KG'
              write_cell(fees_sheet, row, 9, fee[:kg])
              write_cell(fees_sheet, row, 8, fee[:cbm])
              write_cell(fees_sheet, row, 14, fee[:min])
            when 'PER_WM'
              write_cell(fees_sheet, row, 15, fee[:value])
            when 'PERCENTAGE'
              write_cell(fees_sheet, row, 16, fee[:value])
            end
            row += 1
          end
        end
      end
    end

    def write_rates_to_sheet # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      pages.values.each_with_index do |page, i| # rubocop:disable Metrics/BlockLength
        @rates_sheet = @books[hub.id][load_type].sheets.create(organization_id: @organization.id, sheet_index: i + 2)
        write_cell(rates_sheet, 3, 0, 'ZONE')
        write_cell(rates_sheet, 3, 1, 'MIN')
        write_cell(rates_sheet, 4, 0, 'MIN')
        minimums = {}
        row = 5
        column = 2
        meta_column = 0
        page[:meta].each do |key, value|
          write_cell(rates_sheet, 0, meta_column, key.upcase)
          write_cell(rates_sheet, 1, meta_column, value)
          meta_column += 1
        end

        page[:pricings].values.first['truckingPricing']['rates'].each do |key, rates_array|
          rates_array.each do |rate|
            next unless rate

            write_cell(rates_sheet, 2, column, key.downcase)
            write_cell(rates_sheet, 3, column, "#{rate["min_#{key}"]} - #{rate["max_#{key}"]}")
            column += 1
          end
        end
        page[:pricings].values.each_with_index do |result, pi|
          write_cell(rates_sheet, row, 0, pi)
          write_cell(rates_sheet, row, 1, result['truckingPricing']['rates'].first[1][0]['min_value'])
          minimums[pi] = result['truckingPricing']['rates'].first[1][0]['min_value']
          column = 2
          result['truckingPricing']['rates'].each_value do |rates_array|
            rates_array.each do |rate|
              next unless rate

              if rate['min_value']
                write_cell(rates_sheet, row, 1, rate['min_value'].round(2))
              else
                write_cell(rates_sheet, row, 1, 0)
              end
              write_cell(rates_sheet, row, column, rate['rate']['value'].round(2))
              column += 1
            end
          end
          row += 1
        end
      end
    end

    def prep_results # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      page_groupings = @data.group_by do |trucking_result|
        [
          trucking_result.dig('truckingPricing', 'truck_type'),
          trucking_result.dig('truckingPricing', 'cargo_class'),
          trucking_result.dig('truckingPricing', 'load_type'),
          trucking_result.dig('truckingPricing', 'direction')
        ].join('_')
      end

      page_groupings.values.each do |page_values|
        meta = build_meta(page_values.first)
        grouped_results = page_values.group_by { |trucking_result| trucking_result['truckingPricing']['parent_id'] }
        grouped_results.values.each do |values|
          trucking = values.first['truckingPricing']
          next if trucking['rates'].empty?

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

    def consecutive_arrays(ary)
      ary.sort.slice_when { |x, y| (x.to_i + 1) != y.to_i }.map do |c_ary|
        if c_ary.length == 1
          "#{c_ary.first} - #{c_ary.first}"
        elsif identifier == 'zipCode'
          "#{(c_ary.first.to_d / 1000).floor * 1000} - #{(c_ary.last.to_d / 1000).ceil * 1000}"
        else
          "#{c_ary.first} - #{c_ary.last}"
        end
      end
    end

    def build_meta(trucking_result) # rubocop:disable Metrics/AbcSize
      {
        city: hub.nexus.name,
        currency: trucking_result.dig('truckingPricing', 'rates',0, 1, 0, 'rate', 'currency'),
        load_meterage_ratio: trucking_result.dig('truckingPricing', 'load_meterage', 'ratio'),
        load_meterage_limit: trucking_result.dig('truckingPricing', 'load_meterage', 'height_limit'),
        load_meterage_area: trucking_result.dig('truckingPricing', 'load_meterage', 'area_limit'),
        cbm_ratio: trucking_result.dig('truckingPricing', 'cbm_ratio'),
        scale: trucking_result.dig('truckingPricing', 'modifier'),
        rate_basis: trucking_result.dig('truckingPricing', 'rates',0 , 1, 0, 'rate', 'rate_basis'),
        base: trucking_result.dig('truckingPricing', 'rates',0 , 1, 0, 'rate', 'base') || 1,
        truck_type: trucking_result.dig('truckingPricing', 'truck_type'),
        load_type: trucking_result.dig('truckingPricing', 'load_type'),
        cargo_class: trucking_result.dig('truckingPricing', 'cargo_class'),
        direction: trucking_result.dig('truckingPricing', 'carriage') == 'pre' ? 'export' : 'import',
        courier: ::Legacy::TenantVehicle.find(trucking_result.dig('truckingPricing', 'tenant_vehicle_id'))&.name
      }
    end

    def write_cell(sheet, row, col, val)
      @cells << {
        sheet_id: sheet.id,
        organization_id: @organization.id,
        row: row,
        column: col,
        value: val
      }
    end

    private

    attr_reader :purge_ids, :books, :book, :sheet, :hub, :load_type, :identifier, :identifier_modifier,
                  :group_id, :pages, :dir_fees, :zones, :zone_sheet, :fees_sheet, :rates_sheet, :data
  end
end
