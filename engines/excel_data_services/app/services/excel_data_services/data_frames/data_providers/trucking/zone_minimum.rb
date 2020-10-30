# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class ZoneMinimum < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "zone_minimum" => :float
            }
          end

          private

          attr_reader :file, :schema

          def data
            extract_from_schema(section: "row_minimum_data").map(&:data)
          end

          def label
            "zone_minimum"
          end
        end
      end
    end
  end
end
