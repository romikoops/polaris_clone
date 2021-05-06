# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Truckings
        class Metadata < ExcelDataServices::DataFrames::Restructurers::Base
          LOAD_METERAGE_KEYS = %w[
            load_meterage_ratio
            load_meterage_stackable_type
            load_meterage_non_stackable_type
            load_meterage_hard_limit
            load_meterage_stackable_limit
            load_meterage_non_stackable_limit
          ].freeze
          GROUPING_KEYS = %w[cargo_class carriage truck_type].freeze

          def restructured_data
            all_sheet_data = groupings.flat_map do |grouping|
              selected_rows(cargo_class: grouping["cargo_class"], carriage: grouping["carriage"], truck_type: grouping["truck_type"])
                .map { |row| build_trucking_from_row(row: row) }.uniq
            end
            all_sheet_data.uniq { |row| row.slice(*GROUPING_KEYS) }
          end

          def build_trucking_from_row(row:)
            row["load_meterage"] = load_meterage(sheet_name: row["sheet_name"])
            row["identifier_modifier"] = row.delete("query_method")
            row["modifier"] = row.delete("scale")
            row["validity"] = row_validity(row: row)
            row.delete("sheet_name")
            row
          end

          def load_meterage(sheet_name:)
            row = frame[frame["sheet_name"] == sheet_name].to_a.first
            row.slice(*LOAD_METERAGE_KEYS)
              .transform_keys { |key| key.delete_prefix("load_meterage_") }
              .tap do |datum|
                legacy_limit_type = %w[area height].find { |type| row["load_meterage_#{type}"].present? }
                datum["hard_limit"] = datum["hard_limit"].positive?
                datum["stackable_type"] ||= legacy_limit_type
                datum["stackable_limit"] ||= row["load_meterage_#{legacy_limit_type}"]
              end
          end

          def groupings
            @groupings ||= frame[GROUPING_KEYS].to_a.uniq
          end

          def selected_rows(cargo_class:, carriage:, truck_type:)
            frame[(frame["cargo_class"] == cargo_class) & (frame["carriage"] == carriage) & (frame["truck_type"] == truck_type)][default_keys].to_a.uniq
          end

          def default_keys
            %w[
              cbm_ratio
              group_id
              hub_id
              organization_id
              scale
              carriage
              cargo_class
              load_type
              tenant_vehicle_id
              truck_type
              group_id
              sheet_name
              effective_date
              expiration_date
            ]
          end

          def row_validity(row:)
            start_date = row.delete("effective_date")
            end_date = row.delete("expiration_date")
            "[#{start_date}, #{end_date})"
          end
        end
      end
    end
  end
end
