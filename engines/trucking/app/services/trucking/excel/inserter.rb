# frozen_string_literal: true

require 'bigdecimal'

module Trucking
  module Excel
    class Inserter < ::Trucking::Excel::Base # rubocop:disable Metrics/ClassLength
      attr_reader :defaults, :trucking_rate_by_zone, :sheets, :zone_sheet,
                  :fees_sheet, :num_rows, :zip_char_length, :identifier_type, :identifier_modifier, :zones,
                  :all_ident_values_and_countries, :charges, :locations, :valid_postal_codes, :xlsx

      MissingModifierKeys = Class.new(StandardError)
      InvalidSheet = Class.new(StandardError)

      def initialize(_args)
        super
        raise InvalidSheet if xlsx&.sheets.blank?

        @defaults = {}
        @trucking_rate_by_zone = {}
        @tenant = @hub.tenant
        @zip_char_length = nil
        @zones = {}
        @all_ident_values_and_countries = {}
        @charges = {}
        @locations = []
        @trucking_locations = []
        @trucking_rates = []
        @trucking_truckings = []
        @missing_locations = []
      end

      def perform
        start_time = DateTime.now
        @sheets = xlsx.sheets.clone
        @zone_sheet = xlsx.sheet(sheets[0]).clone
        @fees_sheet = xlsx.sheet(sheets[1]).clone
        @num_rows = @zone_sheet&.last_row
        @identifier_type, @identifier_modifier = determine_identifier_type_and_modifier(@zone_sheet.row(1)[1])
        load_zones
        load_ident_values_and_countries
        load_fees_and_charges
        overwrite_zonal_trucking_rates_by_hub
        create_coverage
        end_time = DateTime.now
        diff = (end_time - start_time) / 86_400
        puts @missing_locations
        puts "Time elapsed: #{diff}"

        stats
      end

      def create_coverage
        if ::Trucking::Coverage.exists?(hub_id: @hub.id)
          c = ::Trucking::Coverage.find_by(hub_id: @hub.id, sandbox: @sandbox)
          c.save
        else
          ::Trucking::Coverage.create!(hub_id: @hub.id, sandbox: @sandbox)
        end
      end

      def local_stats
        {
          trucking_rates: {
            number_updated: 0,
            number_created: 0
          },
          trucking_locations: {
            number_updated: 0,
            number_created: 0
          }
        }
      end

      def _results
        {
          trucking_rates: [],
          trucking_locations: []
        }
      end

      def find_availabilities(row_truck_type, direction, load_type, hub)
        query_method = case @identifier_type
                       when 'location_id'
                         :location
                       when 'zipcode'
                         :zipcode
                       when 'distance'
                         :distance
                       else
                         :not_set
                        end
        trucking_type_availability = TypeAvailability.find_or_create_by(
          truck_type: row_truck_type,
          carriage: direction,
          load_type: load_type,
          query_method: query_method,
          sandbox: @sandbox
        )
        HubAvailability.find_or_create_by(
          hub_id: hub.id,
          type_availability_id: trucking_type_availability.id,
          sandbox: @sandbox
        )
      end

      def overwrite_zonal_trucking_rates_by_hub # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
        sheets.slice(2, sheets.length - 1).each do |sheet| # rubocop:disable Metrics/BlockLength
          rates_sheet = xlsx.sheet(sheet)
          meta = generate_meta_from_sheet(rates_sheet)
          row_truck_type = !meta[:truck_type] || meta[:truck_type] == '' ? 'default' : meta[:truck_type]
          direction = meta[:direction] == 'import' ? 'on' : 'pre'

          load_type = meta[:load_type] == 'container' ? 'container' : 'cargo_item'
          direction = meta[:direction] == 'import' ? 'on' : 'pre'

          find_availabilities(row_truck_type, direction, load_type, hub)

          modifier_position_objs = populate_modifier(rates_sheet)
          raise MissingModifierKeys if modifier_position_objs.empty?

          header_row = rates_sheet.row(4)
          header_row.shift
          header_row.shift
          weight_min_row = rates_sheet.row(5)
          weight_min_row.shift
          weight_min_row.shift
          add_values_to_defaults(modifier_position_objs, header_row)

          (6..rates_sheet.last_row).each do |line|
            row_data = rates_sheet.row(line)
            row_zone_name = row_data.shift
            row_min_value = row_data.shift
            next if all_ident_values_and_countries[row_zone_name].nil?

            single_ident_values_and_country = all_ident_values_and_countries[row_zone_name].compact
            next if single_ident_values_and_country.nil? || single_ident_values_and_country.first.nil?

            trucking = create_trucking(meta: meta, sheet_name: sheet, row_number: line)
            stats[:trucking_rates][:number_created] += 1

            modifier_position_objs.each do |mod_key, mod_indexes|
              trucking[:rates][mod_key] = mod_indexes.map do |m_index|
                val = row_data[m_index]

                next unless val

                trucking_rates(weight_min_row, val, meta, row_min_value, row_zone_name, m_index, mod_key)
              end
            end

            modify_charges(trucking, row_truck_type, direction)

            insert_or_update_truckings(trucking, single_ident_values_and_country)
          end
        end
      end

      def insert_or_update_truckings(trucking_rate, single_ident_values_and_country) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        @all_trucking_locations = []
        @all_trucking_truckings = []
        single_ident_values_and_country.each do |ident_and_country|
          tl = Location.find_or_initialize_by(
            @identifier_type.to_s => ident_and_country[:ident],
            country_code: ident_and_country[:country],
            sandbox: @sandbox
          )

          tl.city_name = ident_and_country[:sub_ident] if ident_and_country[:sub_ident]
          tl.city_name = ident_and_country[:ident] if %w[zipcode distance].include?(@identifier_type)

          tl.id ||= SecureRandom.uuid
          next if @all_trucking_locations.include?(tl)

          @all_trucking_locations << tl
          trucking_attr = trucking_rate.slice(
            :hub_id,
            :tenant_id,
            :identifier_modifier,
            :carriage,
            :cargo_class,
            :load_type,
            :courier_id,
            :truck_type,
            :user_id,
            :group_id
          ).merge(location_id: tl.id)
          trucking = ::Trucking::Trucking.find_or_initialize_by(trucking_attr)
          trucking.assign_attributes(trucking_rate.merge(location_id: tl.id))
          trucking.id ||= SecureRandom.uuid
          trucking.parent_id ||= trucking_rate[:parent_id]
          @all_trucking_truckings << trucking
        end

        ::Trucking::Trucking.import(
          @all_trucking_truckings,
          on_duplicate_key_update: :all,
          batch_size: 1000,
          validate_uniqueness: true
        )
        ::Trucking::Location.import(
          @all_trucking_locations,
          on_duplicate_key_update: :all,
          batch_size: 1000,
          validate_uniqueness: true
        )
      end

      def load_zones # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
        (2..num_rows).each do |line| # rubocop:disable Metrics/BlockLength
          row_data = zone_sheet.row(line)
          zone_name = row_data[0]
          zones[zone_name] = [] if zones[zone_name].nil?

          if row_data[1] && !row_data[2]
            row_zip = row_data[1].is_a?(Numeric) ? row_data[1].to_i : row_data[1].strip
            @zip_char_length ||= row_zip.to_s.length
            zones[zone_name] << if identifier_type == 'distance' && identifier_modifier == 'return'
                                  { ident: (row_zip / 2.0).ceil, country: row_data[3].strip }
                                else
                                  { ident: row_zip, country: row_data[3] }
                                end

          elsif !row_data[1] && row_data[2]
            range = row_data[2].delete(' ').split('-')
            @zip_char_length ||= range[0].length
            zones[zone_name] << if identifier_type == 'distance' && identifier_modifier == 'return'
                                  {
                                    min: (range[0].to_i / 2.0).ceil,
                                    max: (range[1].to_i / 2.0).ceil,
                                    country: row_data[3].strip
                                  }
                                else
                                  { min: range[0], max: range[1], country: row_data[3].strip }
                                end

          elsif row_data[1] && row_data[2]
            zones[zone_name] << {
              ident: row_data[1].strip,
              sub_ident: row_data[2].strip,
              country: row_data[3].strip
            }
          end
        end
      end

      def extract_number(string:)
        string.tr('^0-9', '').to_i
      end

      def alphanumeric_range(min:, max:, country:)
        alpha = min.tr('^A-Z', '')
        numeric_min =  extract_number(string: min)
        numeric_max =  extract_number(string: max)
        (numeric_min..numeric_max).map do |numeric|
          alphanumeric = [alpha, numeric].join('')

          { ident: alphanumeric, country: country }
        end
      end

      def determine_sub_ident(string:, location_data:)
        if identifier_modifier == 'locode' && string
          [location_data[:ident].upcase, string].join(' - ')
        elsif identifier_modifier == 'locode' && !string
          location_data[:ident].upcase
        elsif identifier_type == 'location_id' && identifier_modifier.nil?
          "#{string} - #{location_data[:sub_ident].capitalize}"
        else
          string
        end
      end

      def postal_code_range(postal_codes_data:)
        if postal_codes_data[:min][/[a-zA-Z]/].present?
          alphanumeric_range(
            min: postal_codes_data[:min], max: postal_codes_data[:max], country: postal_codes_data[:country]
          ).map do |alphanumeric_data|
            postal_code_range_data(ident_and_country: alphanumeric_data)
          end
        else
          (postal_codes_data[:min].to_i..postal_codes_data[:max].to_i).map do |ident|
            ident_value = if identifier_type == 'zipcode'
                            ident.to_s.rjust(zip_char_length, '0')
                          else
                            ident
                          end

            postal_code_range_data(ident_and_country: { ident: ident_value, country: postal_codes_data[:country] })
          end
        end
      end

      def postal_code_range_data(ident_and_country:)
        return nil if valid_postal_codes&.exclude?(ident_and_country[:ident])

        if identifier_type == 'location_id'
          find_and_prep_geometry(geometry_data: ident_and_country)
        else
          ident_and_country
        end
      end

      def find_and_prep_geometry(geometry_data:)
        geometry = find_geometry(geometry_data)
        if geometry.nil?
          @missing_locations << geometry_data.values.join(', ')
          return nil
        end
        geo_name = geometry&.name
        sub_ident_str = determine_sub_ident(string: geo_name, location_data: geometry_data)
        { ident: geometry&.id, country: geometry_data[:country], sub_ident: sub_ident_str }
      end

      def load_ident_values_and_countries
        current_country = { name: nil, code: nil }

        zones.each do |zone_name, idents_and_countries|
          current_country = {}
          all_ident_values_and_countries[zone_name] = idents_and_countries.flat_map do |idents_and_country|
            if current_country[:code] != idents_and_country[:country]
              current_country = {
                name: Legacy::Country.find_by(code: idents_and_country[:country]).name,
                code: idents_and_country[:country]
              }
              @valid_postal_codes = ::Trucking::PostalCodes.for(country_code: idents_and_country[:country])
            end
            if idents_and_country[:min] && idents_and_country[:max]
              postal_code_range(postal_codes_data: idents_and_country).compact
            elsif identifier_type == 'location_id'
              resp = find_and_prep_geometry(geometry_data: idents_and_country)
              next if resp.blank?

              resp
            else
              idents_and_country
            end
          end
        end
      end

      def parse_fees_sheet
        fees_sheet.parse(
          fee: 'FEE',
          mot: 'MOT',
          fee_code: 'FEE_CODE',
          truck_type: 'TRUCK_TYPE',
          direction: 'DIRECTION',
          currency: 'CURRENCY',
          rate_basis: 'RATE_BASIS',
          ton: 'TON',
          cbm: 'CBM',
          kg: 'KG',
          item: 'ITEM',
          shipment: 'SHIPMENT',
          bill: 'BILL',
          container: 'CONTAINER',
          minimum: 'MINIMUM',
          wm: 'WM',
          percentage: 'PERCENTAGE'
        )
      end

      def load_fees_and_charges # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
        parse_fees_sheet.each do |row| # rubocop:disable Metrics/BlockLength
          fee_row_key = "#{row[:fee_code]}_#{row[:truck_type]}_#{row[:direction]}"
          case row[:rate_basis]
          when 'PER_SHIPMENT'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              value: row[:shipment],
              rate_basis: row[:rate_basis],
              key: row[:fee_code],
              min: row[:minimum],
              name: row[:fee]
            }
          when 'PER_CONTAINER'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              value: row[:container],
              rate_basis: row[:rate_basis],
              key: row[:fee_code],
              min: row[:minimum],
              name: row[:fee]
            }
          when 'PER_BILL'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              value: row[:bill],
              rate_basis: row[:rate_basis],
              key: row[:fee_code],
              min: row[:minimum],
              name: row[:fee]
            }
          when 'PERCENTAGE'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              value: row[:percentage],
              rate_basis: row[:rate_basis],
              key: row[:fee_code],
              min: row[:minimum],
              name: row[:fee]
            }
          when 'PER_CBM'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              value: row[:cbm],
              rate_basis: row[:rate_basis],
              key: row[:fee_code],
              min: row[:minimum],
              name: row[:fee]
            }
          when 'PER_KG'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              value: row[:kg],
              rate_basis: row[:rate_basis],
              min: row[:minimum],
              key: row[:fee_code],
              name: row[:fee]
            }
          when 'PER_WM'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              value: row[:wm],
              rate_basis: row[:rate_basis],
              min: row[:minimum],
              key: row[:fee_code],
              name: row[:fee]
            }
          when 'PER_ITEM'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              value: row[:item],
              rate_basis: row[:rate_basis],
              min: row[:minimum],
              key: row[:fee_code],
              name: row[:fee]
            }
          when 'PER_CBM_TON'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              cbm: row[:cbm],
              ton: row[:ton],
              min: row[:minimum],
              rate_basis: row[:rate_basis],
              key: row[:fee_code],
              name: row[:fee]
            }
          when 'PER_SHIPMENT_CONTAINER'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              shipment: row[:shipment],
              container: row[:container],
              rate_basis: row[:rate_basis],
              min: row[:minimum],
              key: row[:fee_code],
              name: row[:fee]
            }
          when 'PER_BILL_CONTAINER'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              bill: row[:bill],
              container: row[:container],
              rate_basis: row[:rate_basis],
              key: row[:fee_code],
              min: row[:minimum],
              name: row[:fee]
            }
          when 'PER_CBM_KG'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              cbm: row[:cbm],
              kg: row[:kg],
              min: row[:minimum],
              rate_basis: row[:rate_basis],
              key: row[:fee_code],
              name: row[:fee]
            }
          end

          Legacy::ChargeCategory.from_code(code: row[:fee_code].downcase, name: row[:fee], tenant_id: @tenant.id)
        end
      end

      def add_values_to_defaults(modifier_position_objs, header_row)
        modifier_position_objs.each do |mod_key, mod_indexes|
          header_row.each_with_index do |cell, i|
            next if !cell || !mod_indexes.include?(i)

            defaults[mod_key] = {} unless defaults[mod_key]
            min_max_arr = cell.split('-').map(&:strip)
            defaults[mod_key][i] = { "min_#{mod_key}": min_max_arr[0].to_d, "max_#{mod_key}": min_max_arr[1].to_d, min_value: nil }.symbolize_keys
          end
        end
      end

      def populate_modifier(rates_sheet)
        modifier_row = rates_sheet.row(3)
        modifier_row.shift
        modifier_row.shift
        modifier_position_objs = {}

        modifier_row.uniq.each do |mod|
          unless mod.nil?
            modifier_position_objs[mod] = modifier_row.each_index.select { |index| modifier_row[index] == mod }
          end
        end
        modifier_position_objs
      end

      def create_trucking(meta:, sheet_name:, row_number:) # rubocop:disable Metrics/AbcSize
        user_id = meta[:user_email] ? User.find_by(tenant_id: @tenant.id, email: meta[:user_email])&.id : nil
        {
          load_meterage: {
            ratio: meta[:load_meterage_ratio],
            height_limit: meta[:load_meterage_height],
            area_limit: meta[:load_meterage_area],
            ldm_limit: meta[:load_meterage_ldm]
          },
          rates: {},
          parent_id: SecureRandom.uuid,
          user_id: user_id,
          fees: {},
          cbm_ratio: meta[:cbm_ratio],
          modifier: meta[:scale],
          hub_id: @hub.id,
          group_id: @group_id,
          tenant_id: tenant.id,
          identifier_modifier: identifier_modifier,
          carriage: meta[:direction] == 'import' ? 'on' : 'pre',
          cargo_class: meta[:cargo_class],
          load_type: meta[:load_type] == 'container' ? 'container' : 'cargo_item',
          courier_id: find_or_create_courier(meta[:courier]).id,
          truck_type: !meta[:truck_type] || meta[:truck_type] == '' ? 'default' : meta[:truck_type],
          sandbox: @sandbox,
          metadata: metadata(row_number: row_number, sheet_name: sheet_name)
        }
      end

      def metadata(row_number:, sheet_name:)
        meta_data = {
          row_number: row_number,
          sheet_name: sheet_name,
          file_name: document&.file&.filename&.to_s,
          document_id: document&.id
        }
        return meta_data if document.blank?

        meta_data[:document_id] = document.id
        return meta_data unless document.file.attached?

        meta_data[:file_name] = document.file.filename.to_s

        meta_data
      end

      def trucking_rates(weight_min_row, val, meta, row_min_value, _row_zone_name, m_index, mod_key) # rubocop:disable Metrics/PerceivedComplexity, Metrics/ParameterLists, Metrics/CyclomaticComplexity
        val *= 2 if identifier_type == 'distance' && identifier_modifier == 'return' && mod_key == 'km'
        w_min = weight_min_row[m_index] || 0
        r_min = row_min_value || 0
        if defaults[mod_key]
          defaults[mod_key][m_index].clone.merge(
            min_value: [w_min, r_min].max,
            rate: {
              value: val,
              rate_basis: meta[:rate_basis],
              currency: meta[:currency],
              base: meta[:base]
            }
          )
        else
          {
            min_value: 0,
            rate: {
              value: val,
              rate_basis: meta[:rate_basis],
              currency: meta[:currency],
              base: meta[:base]
            }
          }
        end
      end

      def modify_charges(trucking_rate, row_truck_type, direction)
        direction_str = if %w[import export].include?(direction)
                          direction
                        else
                          direction == 'pre' ? 'export' : 'import'
                        end
        charges.each do |_k, fee|
          tmp_fee = fee.clone
          next unless tmp_fee[:direction] == direction_str && tmp_fee[:truck_type] == row_truck_type

          tmp_fee.delete(:direction)
          tmp_fee.delete(:truck_type)
          trucking_rate[:fees][tmp_fee[:key]] = tmp_fee
        end
      end

      def identity_country(single_ident_values_and_country)
        case identifier_type
        when 'distance', 'location_id'
          single_ident_values_and_country.map do |h|
            "('#{h[:ident]}', '#{h[:country]}', current_timestamp, current_timestamp)"
          end
        else
          single_ident_values_and_country.map do |h|
            "('#{h[:ident]}', '#{h[:country]}', current_timestamp, current_timestamp)"
          end
        end.join(', ')
      end

      def find_or_create_courier(courier_name)
        Courier.find_or_create_by(name: courier_name, tenant: tenant)
      end

      def build_trucking_and_locations(single_ident_values_and_country, rate)
        single_ident_values_and_country.each do |values|
          location = Location.find_or_initialize_by(
            'country_code' => values[:country].downcase,
            identifier_type.to_s => values[:ident]
          )
          @trucking_locations << location
          trucking = Trucking.find_or_initialize_by(
            hub: @hub,
            rate: rate,
            location: location
          )
          @trucking_truckings << trucking
        end
      end

      def determine_identifier_type_and_modifier(identifier_type) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        if identifier_type == 'CITY'
          'location_id'
        elsif identifier_type == 'POSTAL_CODE'
          %w[location_id postal_code]
        elsif identifier_type == 'LOCODE'
          %w[location_id locode]
        elsif identifier_type == 'POSTAL_CITY'
          %w[location_id postal_city]
        elsif identifier_type.include?('_')
          identifier_type.split('_').map(&:downcase)
        elsif identifier_type.include?(' ')
          identifier_type.split(' ').map(&:downcase)
        else
          [identifier_type.downcase, false]
        end
      end

      def generate_meta_from_sheet(sheet)
        meta = {}
        sheet.row(1).each_with_index do |key, i|
          next if key.nil?

          meta[key.downcase] = sheet.row(2)[i]
        end
        meta.deep_symbolize_keys!
      end

      def find_geometry(idents_and_country) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        geometry = if @identifier_modifier == 'postal_code'
                     Locations::Location.find_by(
                       name: idents_and_country[:ident].upcase,
                       country_code: idents_and_country[:country].downcase
                     )
                   elsif @identifier_modifier == 'locode'
                     Locations::LocationSeeder.seeding_with_locode(locode: idents_and_country[:ident].upcase)
                   elsif @identifier_modifier == 'postal_city'
                     postal_code, name = idents_and_country[:ident].split('-').map { |string| string.strip.upcase }
                     Locations::LocationSeeder.seeding_with_postal_code(
                       postal_code: postal_code,
                       country_code: idents_and_country[:country].downcase,
                       terms: name
                     )
                   else
                     Locations::LocationSeeder.seeding(
                       [idents_and_country[:ident],
                        idents_and_country[:sub_ident]],
                       idents_and_country[:country].downcase
                     )
                  end

        puts idents_and_country if geometry.nil?
        if geometry.nil?
          geocoder_results = Geocoder.search(
            idents_and_country.values.join(' '),
            params: { region: idents_and_country[:country].downcase }
          )
          return nil if geocoder_results.first.nil?

          coordinates = geocoder_results.first.geometry['location']
          geometry = Locations::Location.smallest_contains(lat: coordinates['lat'], lon: coordinates['lng']).first
        end

        geometry
      end
    end
  end
end
