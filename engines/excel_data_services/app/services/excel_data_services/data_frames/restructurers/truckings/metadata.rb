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

          def restructured_data
            groupings.flat_map do |sheet_name|
              rows = frame[frame["sheet_name"] == sheet_name][default_keys].to_a.uniq
              rows.map do |row|
                build_trucking_from_row(row: row, sheet_name: sheet_name)
              end
            end
          end

          def build_trucking_from_row(row:, sheet_name:)
            row["load_meterage"] = load_meterage(sheet_name: sheet_name)
            row["identifier_modifier"] = row.delete("query_method")
            row["modifier"] = row.delete("scale")
            row["validity"] = row_validity(row: row)
            row
          end

          def load_meterage(sheet_name:)
            frame[frame["sheet_name"] == sheet_name].to_a.first
              .slice(*LOAD_METERAGE_KEYS)
              .transform_keys { |key| key.delete_prefix("load_meterage_") }
              .tap { |datum| datum["hard_limit"] = datum["hard_limit"].positive? }
          end

          def groupings
            @groupings ||= frame["sheet_name"].uniq.to_a
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
