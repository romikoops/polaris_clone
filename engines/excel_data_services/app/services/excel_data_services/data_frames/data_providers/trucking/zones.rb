# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class Zones < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "zone" => :object,
              "primary" => :object,
              "secondary" => :object,
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
                "primary" => primaries,
                "secondary" => secondaries,
                "country_code" => country_codes,
                "zone" => zones,
                "zone_row" => zone_rows
              },
              types: column_types
            )
          end

          def zones
            extract_from_schema(section: "zones").map(&:value)
          end

          def primaries
            extract_from_schema(section: "primary").map(&:value)
          end

          def secondaries
            extract_from_schema(section: "secondary").map(&:value)
          end

          def country_codes
            extract_from_schema(section: "country").map(&:value)
          end

          def zone_rows
            extract_from_schema(section: "zones").map(&:row)
          end

          def label
            "zone"
          end
        end
      end
    end
  end
end
