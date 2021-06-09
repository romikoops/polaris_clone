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
            extract_from_schema(section: "row_minimum_data").map do |cell|
              parse_cell_data(header: label, cell: cell)
            end
          end

          def label
            "zone_minimum"
          end

          def last_sheet_col_section
            "row_minimum_data"
          end
        end
      end
    end
  end
end
