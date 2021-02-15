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
            Rover::DataFrame.new(
              {
                "primary" => primaries,
                "secondary" => secondaries,
                "country_code" => country_codes,
                "zone" => zones,
                "zone_row" => zone_rows
              },
              types: column_types
            ).tap do |frame|
              frame["query_method"] = query_method
              frame["identifier"] = identifier
            end
          end

          def zones
            extract_from_schema(section: "zones").map do |cell|
              parse_cell_value(header: "zone", cell: cell)
            end
          end

          def primaries
            extract_from_schema(section: "primary").map do |cell|
              parse_cell_value(header: "primary_#{identifier}", cell: cell)
            end
          end

          def secondaries
            extract_from_schema(section: "secondary").map do |cell|
              parse_cell_value(header: "secondary_#{identifier}", cell: cell)
            end
          end

          def country_codes
            extract_from_schema(section: "country").map do |cell|
              parse_cell_value(header: "country_code", cell: cell)
            end
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
