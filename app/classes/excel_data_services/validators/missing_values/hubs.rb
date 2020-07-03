# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module MissingValues
      class Hubs < ExcelDataServices::Validators::MissingValues::Base
        VALID_HUB_TYPES = %w[
          ocean
          rail
          truck
          air
        ].freeze

        USER_FRIENDLY_KEY_LOOKUP = {
          organization_id: 'ORGANIZATION',
          hub_type: 'HUB TYPE',
          latitude: 'LATITUDE',
          longitude: 'LONGITUDE',
          name: 'NAME',
          hub_code: 'LOCODE',
          locode: 'LOCODE',
          geocoded_address: 'FULL ADDRESS',
          city: 'CITY'
        }.freeze

        private

        def check_single_data(row)
          check_row_hub(row: row)
          check_row_nexus(row: row)
          check_row_address(row: row)
        end

        def check_row_hub(row:)
          %i[organization_id
             hub_type
             latitude
             longitude
             name
             hub_code].each do |hub_attr_key|
            next if row[:hub][hub_attr_key].present?

            add_to_errors(
              type: :error,
              row_nr: row[:row_nr],
              sheet_name: sheet_name,
              reason: "Missing value for #{USER_FRIENDLY_KEY_LOOKUP[hub_attr_key]}.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValuesForHub
            )
          end
        end

        def check_row_nexus(row:)
          %i[organization_id
             latitude
             longitude
             name
             locode].each do |hub_attr_key|
            next if row[:nexus][hub_attr_key].present?

            add_to_errors(
              type: :error,
              row_nr: row[:row_nr],
              sheet_name: sheet_name,
              reason: "Missing value for #{USER_FRIENDLY_KEY_LOOKUP[hub_attr_key]}.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValuesForHub
            )
          end
        end

        def check_row_address(row:)
          %i[geocoded_address
             latitude
             longitude
             city
             country].each do |hub_attr_key|
            next if row[:address][hub_attr_key].present?

            add_to_errors(
              type: :error,
              row_nr: row[:row_nr],
              sheet_name: sheet_name,
              reason: "Missing value for #{USER_FRIENDLY_KEY_LOOKUP[hub_attr_key]}.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValuesForHub
            )
          end
        end
      end
    end
  end
end
