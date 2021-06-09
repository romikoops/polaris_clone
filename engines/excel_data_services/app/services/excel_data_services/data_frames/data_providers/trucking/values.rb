# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class Values < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "value" => :object
            }
          end

          private

          def data
            extract_from_schema(section: "main_data").map do |cell|
              parse_cell_data(header: label, cell: cell)
            end
          end

          def label
            "value"
          end

          def last_sheet_col_section
            "main_data"
          end
        end
      end
    end
  end
end
