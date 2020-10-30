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
            rows_frame_with_query_method
          end

          def rows_frame
            @rows_frame ||= Rover::DataFrame.new(
              {
                "country_code" => country_codes
              },
              types: column_types
            )
          end

          def country_codes
            extract_from_schema(section: "country").map(&:value)
          end

          def label
            "country_code"
          end
        end
      end
    end
  end
end
