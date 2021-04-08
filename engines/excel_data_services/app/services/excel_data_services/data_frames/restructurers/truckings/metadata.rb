# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Truckings
        class Metadata < ExcelDataServices::DataFrames::Restructurers::Base
          def restructured_data
            groupings.flat_map do |sheet_name|
              rows = frame[frame["sheet_name"] == sheet_name][default_keys].to_a.uniq
              rows.map do |row|
                build_trucking_from_row(row: row)
              end
            end
          end

          def build_trucking_from_row(row:)
            row["load_meterage"] = load_meterage(row: row)
            row["identifier_modifier"] = row.delete("query_method")
            row["modifier"] = row.delete("scale")
            row["validity"] = row_validity(row: row)
            row
          end

          def load_meterage(row:)
            %w[load_meterage_ratio load_meterage_limit load_meterage_area].each_with_object({}) do |key, hash|
              hash[key] = row[key]
            end
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
