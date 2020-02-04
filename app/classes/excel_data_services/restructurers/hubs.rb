# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class Hubs < ExcelDataServices::Restructurers::Base # rubocop:disable Metrics/ClassLength
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
        restructured_data = data[:rows_data].map do |row|
          row = confirm_lat_lngs(row: row)
          row = apply_downcase(row: row)
          row = apply_upcase(row: row)
          row = apply_booleans(row: row)
          {
            address: address_section(row: row),
            nexus: nexus_section(row: row),
            mandatory_charge: mandatory_charge_section(row: row),
            hub: hub_section(row: row),
            row_nr: row[:row_nr]
          }
        end

        { 'Hubs' => restructured_data }
      end

      def confirm_lat_lngs(row:)
        return row if row[:latitude].present? && row[:longitude].present?

        target_address = row[:full_address] || [row[:name], row[:country]].join(', ')

        lat, lng = Address.new(geocoded_address: target_address).geocode
        row[:latitude] = lat
        row[:longitude] = lng
        row[:full_address] = target_address if row[:full_address].blank?

        row
      end

      def address_section(row:)
        {

          name: row[:name],
          latitude: row[:latitude],
          longitude: row[:longitude],
          country: { name: row[:country] },
          city: row[:name],
          geocoded_address: row[:full_address],
          sandbox: @sandbox

        }
      end

      def nexus_section(row:)
        {
          name: row[:name],
          latitude: row[:latitude],
          longitude: row[:longitude],
          photo: row[:photo],
          locode: row[:locode],
          country: { name: row[:country] },
          tenant_id: tenant.id,
          sandbox: @sandbox
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
          tenant_id: tenant.id,
          hub_type: row[:type],
          latitude: row[:latitude],
          longitude: row[:longitude],
          name: append_hub_suffix(row[:name], row[:type]),
          photo: row[:photo],
          sandbox: @sandbox,
          hub_code: row[:locode]
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
          row[sym] = row[sym].present? && TRUE_SYNONYMS.include?(row[sym].downcase)
        end
        row
      end
    end
  end
end
