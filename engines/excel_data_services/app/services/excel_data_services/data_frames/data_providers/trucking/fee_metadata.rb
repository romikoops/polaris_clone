# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class FeeMetadata < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "direction" => :object,
              "carrier" => :object,
              "truck_type" => :object,
              "service" => :object,
              "cargo_class" => :object,
              "mode_of_transport" => :object,
              "sheet_name" => :object
            }
          end

          private

          attr_reader :file, :schema, :count

          def headers
            all_headers.select { |head| %w[carrier service cargo_class direction truck_type].include?(head.value.downcase) }
          end

          def all_headers
            extract_from_schema(section: "metadata_headers") |
              extract_from_schema(section: "optional_metadata_headers")
          end

          def cell_data
            extract_from_schema(section: "metadata_data")
          end

          def label
            "fee_metadata"
          end

          def state_keys
            %w[hub_id group_id organization_id]
          end

          def last_sheet_col_section
            "optional_metadata_headers"
          end
        end
      end
    end
  end
end
