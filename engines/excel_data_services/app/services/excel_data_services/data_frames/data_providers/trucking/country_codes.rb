# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class CountryCodes < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "country_code" => :object
            }
          end

          private

          attr_reader :schema

          def data
            Rover::DataFrame.new(
              {
                "country_code" => country_codes
              },
              types: column_types
            ).tap do |frame|
              frame["query_method"] = query_method
              frame["identifier"] = identifier
            end
          end

          def country_codes
            extract_from_schema(section: "country").map do |cell|
              parse_cell_value(header: label, cell: cell)
            end
          end

          def label
            "country_code"
          end
        end
      end
    end
  end
end
