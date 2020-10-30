# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class Hubs < ExcelDataServices::Restructurers::Base
      COLS_TO_DOWNCASE = %i[
        type
      ].freeze

      COLS_TO_UPCASE = %i[
        locode
      ].freeze

      COLS_TO_BOOLEAN = %i[
        import_charges
        export_charges
        pre_carriage
        on_carriage
        free_out
      ].freeze

      TRUE_SYNONYMS = %w[
        t
        true
      ].freeze

      def perform
        restructured_data = downcase_values(rows_data: data[:rows_data], keys: COLS_TO_DOWNCASE)
        restructured_data = upcase_values(rows_data: restructured_data, keys: COLS_TO_UPCASE)
        restructured_data = restructured_data.map { |row|
          row = confirm_lat_lngs(row: row)
          row = apply_booleans(row: row)
          {
            address: address_section(row: row),
            nexus: nexus_section(row: row),
            mandatory_charge: mandatory_charge_section(row: row),
            hub: hub_section(row: row),
            row_nr: row[:row_nr]
          }
        }

        {"Hubs" => restructured_data}
      end

      def confirm_lat_lngs(row:)
        return row if row.values_at(:latitude, :longitude, :full_address).all?

        if row.values_at(:latitude, :longitude).any?(&:nil?)
          geocode_params = row[:full_address] || [row[:name], row[:country]].join(", ")
          row[:latitude], row[:longitude] = Legacy::Address.new(geocoded_address: geocode_params).geocode
        end
        row[:full_address] ||= begin
          lat, lng = row.values_at(:latitude, :longitude)
          Legacy::Address.new(latitude: lat, longitude: lng).reverse_geocode.geocoded_address
        end

        row
      end

      def address_section(row:)
        {

          name: row[:name],
          latitude: row[:latitude],
          longitude: row[:longitude],
          country: {name: row[:country]},
          city: row[:name],
          geocoded_address: row[:full_address]
        }
      end

      def nexus_section(row:)
        {
          name: row[:name],
          latitude: row[:latitude],
          longitude: row[:longitude],
          locode: row[:locode],
          country: {name: row[:country]},
          organization_id: organization.id
        }
      end

      def mandatory_charge_section(row:)
        {
          pre_carriage: row[:pre_carriage],
          on_carriage: row[:on_carriage],
          import_charges: row[:import_charges],
          export_charges: row[:export_charges]
        }
      end

      def hub_section(row:)
        {
          organization_id: organization.id,
          hub_type: row[:type],
          latitude: row[:latitude],
          longitude: row[:longitude],
          name: row[:name],
          hub_code: row[:locode],
          terminal: row[:terminal],
          terminal_code: row[:terminal_code]
        }
      end

      def apply_downcase(row:)
        COLS_TO_DOWNCASE.each do |sym|
          row[sym].downcase! if row[sym].present?
        end
        row
      end

      def apply_upcase(row:)
        COLS_TO_UPCASE.each do |sym|
          row[sym].upcase! if row[sym].present?
        end
        row
      end

      def apply_booleans(row:)
        COLS_TO_BOOLEAN.each do |sym|
          next if row[sym].in?([true, false])

          row[sym] = row[sym].present? && TRUE_SYNONYMS.include?(row[sym].downcase)
        end
        row
      end
    end
  end
end
