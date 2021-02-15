# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class BracketMinimum < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "bracket_minimum" => :object
            }
          end

          private

          attr_reader :file, :schema

          def data
            extract_from_schema(section: "col_minimum_data").map do |cell|
              parse_cell_data(header: label, cell: cell)
            end
          end

          def label
            "bracket_minimum"
          end
        end
      end
    end
  end
end
