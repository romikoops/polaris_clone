# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class Metadata < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "load_meterage_hard_limit" => :bool,
              "load_meterage_stackable_type" => :object,
              "load_meterage_non_stackable_type" => :object,
              "load_meterage_height" => :object,
              "load_meterage_area" => :object,
              "load_meterage_limit" => :object,
              "identifier_modifier" => :object,
              "city" => :object,
              "currency" => :object,
              "load_meterage_ratio" => :object,
              "load_meterage_stackable_limit" => :object,
              "load_meterage_non_stackable_limit" => :object,
              "cbm_ratio" => :float,
              "scale" => :object,
              "rate_basis" => :object,
              "base" => :object,
              "truck_type" => :object,
              "load_type" => :object,
              "cargo_class" => :object,
              "direction" => :object,
              "carrier" => :object,
              "service" => :object,
              "hub_id" => :object,
              "group_id" => :object,
              "organization_id" => :object,
              "effective_date" => :object,
              "expiration_date" => :object,
              "mode_of_transport" => :object,
              "sheet_name" => :object
            }
          end

          private

          attr_reader :count, :schema

          def headers
            extract_from_schema(section: "metadata_headers") |
              extract_from_schema(section: "optional_metadata_headers")
          end

          def cell_data
            extract_from_schema(section: "metadata_data")
          end

          def label
            "metadata"
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
