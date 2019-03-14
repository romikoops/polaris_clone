# frozen_string_literal: true

require 'bigdecimal'

module Trucking
  module Excel
    class Inserter < ::Trucking::Excel::Base # rubocop:disable Metrics/ClassLength
      attr_reader :defaults, :trucking_rate_by_zone, :sheets, :zone_sheet,
                  :fees_sheet, :num_rows, :zip_char_length, :identifier_type, :identifier_modifier, :zones,
                  :all_ident_values_and_countries, :charges, :locations

      def initialize(_args)
        super

        @defaults = {}
        @trucking_rate_by_zone = {}
        @tenant = @hub.tenant
        @sheets = @xlsx.sheets.clone
        @zone_sheet = @xlsx.sheet(sheets[0]).clone
        @fees_sheet = @xlsx.sheet(sheets[1]).clone
        @num_rows = @zone_sheet.last_row
        @zip_char_length = nil
        @identifier_type, @identifier_modifier = determine_identifier_type_and_modifier(@zone_sheet.row(1)[1])
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
        load_zones
        load_ident_values_and_countries
        load_fees_and_charges
        overwrite_zonal_trucking_rates_by_hub
        end_time = DateTime.now
        diff = (end_time - start_time) / 86_400
        puts @missing_locations
        puts "Time elapsed: #{diff}"
        { results: results, stats: stats }
      rescue => e
        binding.pry
      end

      private

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

      def overwrite_zonal_trucking_rates_by_hub # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
        sheets.slice(2, sheets.length - 1).each do |sheet| # rubocop:disable Metrics/BlockLength
          rates_sheet = xlsx.sheet(sheet)
          meta = generate_meta_from_sheet(rates_sheet)
          row_truck_type = !meta[:truck_type] || meta[:truck_type] == '' ? 'default' : meta[:truck_type]
          direction = meta[:direction] == 'import' ? 'on' : 'pre'

          load_type = meta[:load_type] == 'container' ? 'container' : 'cargo_item'
          cargo_class = meta[:cargo_class]
          direction = meta[:direction] == 'import' ? 'on' : 'pre'
          courier = Courier.find_or_create_by(name: meta[:courier], tenant: tenant)

          trucking_type_availability = TypeAvailability.find_or_create_by(
            truck_type: row_truck_type,
            carriage: direction,
            load_type: load_type
          )
          HubAvailability.find_or_create_by(
            hub_id: hub.id,
            type_availability_id: trucking_type_availability.id
          )

          modifier_position_objs = populate_modifier(rates_sheet)
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
            single_ident_values_and_country = all_ident_values_and_countries[row_zone_name].compact
            next if single_ident_values_and_country.nil? || single_ident_values_and_country.first.nil?

            single_ident_values = single_ident_values_and_country.map { |h| h[:ident] }
            trucking_rate = create_trucking_rate(meta)
            stats[:trucking_rates][:number_created] += 1

            modifier_position_objs.each do |mod_key, mod_indexes|
              trucking_rate.rates[mod_key] = mod_indexes.map do |m_index|
                val = row_data[m_index]

                next unless val

                trucking_rates(weight_min_row, val, meta, row_min_value, row_zone_name, m_index, mod_key)
              end
            end

            modify_charges(trucking_rate, row_truck_type, direction)
            tp = trucking_rate
            td_query = build_td_query(single_ident_values, single_ident_values_and_country)
            td_ids = ActiveRecord::Base.connection.execute(td_query).values.flatten
            delete_previous_trucking_rates(hub, td_ids)
            insertion_query = build_insert_query(tp, td_ids)
            ActiveRecord::Base.connection.execute(insertion_query)
          end
        end
      end

      def delete_previous_trucking_rates(hub, td_ids)
        old_tp_ids =
          Rate.joins(truckings: :location)
              .where('trucking_truckings.hub_id': hub.id)
              .where('trucking_locations.id': td_ids)
              .where(scope: @trucking_rate_scope)
              .distinct.ids

        return if old_tp_ids.empty?

        hub.truckings.where(rate_id: old_tp_ids).delete_all
        Rate.where(id: old_tp_ids).delete_all
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
                                  { min: (range[0].to_i / 2.0).ceil, max: (range[1].to_i / 2.0).ceil, country: row_data[3].strip }
                                else
                                  { min: range[0].to_i, max: range[1].to_i, country: row_data[3].strip }
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

      def load_ident_values_and_countries # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
        current_country = { name: nil, code: nil }
        zones.each do |zone_name, idents_and_countries| # rubocop:disable Metrics/BlockLength
          current_country = {
            name: Legacy::Country.find_by_code(idents_and_countries.first[:country]).name,
            code: idents_and_countries.first[:country]
          }
          all_ident_values_and_countries[zone_name] = idents_and_countries.flat_map do |idents_and_country| # rubocop:disable Metrics/BlockLength
            if current_country[:code] != idents_and_country[:country]
              current_country = {
                name: Legacy::Country.find_by_code(idents_and_country[:country]).name,
                code: idents_and_country[:country]
              }
            end
            if idents_and_country[:min] && idents_and_country[:max]
              (idents_and_country[:min].to_i..idents_and_country[:max].to_i).map do |ident|
                stats[:trucking_locations][:number_created] += 1
                ident_value = nil
                if identifier_type == 'zipcode'
                  ident_length = ident.to_s.length
                  ident_value = '0' * (zip_char_length - ident_length) + ident.to_s
                else
                  ident_value = ident
                end

                { ident: ident_value, country: idents_and_country[:country] }
              end
            elsif identifier_type == 'location_id'
              geometry = find_geometry(idents_and_country)

              if geometry.nil?

                @missing_locations << idents_and_country.values.join(', ')
                next
              end
              stats[:trucking_locations][:number_created] += 1

              { ident: geometry&.id, country: idents_and_country[:country] }
            else
              idents_and_country
            end
          end
        end
      end

      def import_locations
        Locations::Location.import(@locations)
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

      def load_fees_and_charges # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
              name: row[:fee]
            }
          when 'PER_KG'
            charges[fee_row_key] = {
              direction: row[:direction],
              truck_type: row[:truck_type],
              currency: row[:currency],
              value: row[:cbm],
              rate_basis: row[:rate_basis],
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

          ::ChargeCategory.find_or_create_by!(code: row[:fee_code].downcase, name: row[:fee])
        end
      end

      def add_values_to_defaults(modifier_position_objs, header_row)
        modifier_position_objs.each do |mod_key, mod_indexes|
          header_row.each_with_index do |cell, i|
            next if !cell || !mod_indexes.include?(i)

            defaults[mod_key] = {} unless defaults[mod_key]
            min_max_arr = cell.split(' - ')
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
          modifier_position_objs[mod] = modifier_row.each_index.select { |index| modifier_row[index] == mod } unless mod.nil?
        end
        modifier_position_objs
      end

      def create_trucking_rate(meta)
        @trucking_rate_scope = Scope.find_or_create_by(
          carriage: meta[:direction] == 'import' ? 'on' : 'pre',
          cargo_class: meta[:cargo_class],
          load_type: meta[:load_type] == 'container' ? 'container' : 'cargo_item',
          courier_id: find_or_create_courier(meta[:courier]).id,
          truck_type: !meta[:truck_type] || meta[:truck_type] == '' ? 'default' : meta[:truck_type]
        )
        Rate.new(
          load_meterage: {
            ratio: meta[:load_meterage_ratio],
            height_limit: meta[:load_meterage_height],
            area_limit: meta[:load_meterage_area]
          },
          rates: {},
          fees: {},
          cbm_ratio: meta[:cbm_ratio],
          modifier: meta[:scale],
          tenant_id: tenant.id,
          identifier_modifier: identifier_modifier,
          scope: @trucking_rate_scope
        )
      end

      def trucking_rates(weight_min_row, val, meta, row_min_value, _row_zone_name, m_index, mod_key) # rubocop:disable Metrics/PerceivedComplexity, Metrics/ParameterLists
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
        direction_str = direction == 'pre' ? 'export' : 'import'
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

      def build_td_query(single_ident_values, single_ident_values_and_country)
        identifier_cast = case identifier_type
                          when 'location_id'
                            '::uuid'
                          when 'distance'
                            '::integer'
                          else
                            ''
                          end

        <<-SQL
          WITH
            existing_identifiers AS (
              SELECT id, #{identifier_type}, country_code FROM trucking_locations
              WHERE trucking_locations.#{identifier_type} IN ('#{single_ident_values.join("','")}')
                AND trucking_locations.country_code::text = '#{single_ident_values_and_country.first[:country]}'
            ),
            inserted_td_ids AS (
              INSERT INTO trucking_locations(#{identifier_type}, country_code, created_at, updated_at)
                -- insert non-existent trucking_locations
                SELECT ident_value#{identifier_cast}, country_code::text, cr_at, up_at
                FROM (VALUES #{identity_country(single_ident_values_and_country)})
                  AS t(ident_value, country_code, cr_at, up_at)
                WHERE ident_value::text NOT IN (
                  SELECT #{identifier_type}::text
                  FROM existing_identifiers
                  WHERE country_code::text = '#{single_ident_values_and_country.first[:country]}'
                )
              RETURNING id
            )
          SELECT id FROM inserted_td_ids
          UNION
          SELECT id FROM existing_identifiers
        SQL
      end

      def build_insert_query(tp, td_ids)
        tp_names = Rate.attribute_names.reject { |k| k == 'id' }
        tp_insertable = tp.to_postgres_array(tp_names)

        <<-SQL
          WITH
            td_ids   AS (SELECT id from trucking_locations WHERE id IN #{string_sql_format(td_ids)}),
            hub_ids  AS (VALUES(#{hub_id})),
            t_stamps AS (VALUES(current_timestamp)),
            tp_ids AS (
              INSERT INTO trucking_rates(#{tp_names.sort.join(', ')})
                VALUES #{tp_insertable.sql_format}
              RETURNING id
            )
          INSERT INTO trucking_truckings(hub_id, rate_id, location_id, created_at, updated_at)
            (
              SELECT * FROM hub_ids
              CROSS JOIN tp_ids
              CROSS JOIN td_ids
              CROSS JOIN t_stamps AS created_ats
              CROSS JOIN t_stamps AS updated_ats
            );
        SQL
      end

      def determine_identifier_type_and_modifier(identifier_type) # rubocop:disable Metrics/PerceivedComplexity
        if identifier_type == 'CITY'
          'location_id'
        elsif identifier_type == 'POSTAL_CODE'
          %w(location_id postal_code)
        elsif identifier_type == 'LOCODE'
          %w(location_id locode)
        elsif identifier_type == 'POSTAL_CITY'
          %w(location_id postal_city)
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

      def find_geometry(idents_and_country) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
                       idents_and_country[:sub_ident],
                       idents_and_country[:ident]
                     )
                  end

        # if geometry.nil?
        #   geocoder_results = Geocoder.search(idents_and_country.values.join(' '))
        #   return nil if geocoder_results.first.nil?

        #   coordinates = geocoder_results.first.geometry['location']
        #   geometry = Locations::Location.smallest_contains(lat: coordinates['lat'], lon: coordinates['lng']).first
        # end

        geometry
      end

      def string_sql_format(array)
        "(#{array.map { |x| "'#{x}'" }.join(', ')})"
      end
    end
  end
end
