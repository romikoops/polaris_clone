# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      class Cell
        attr_reader :row, :col, :value, :label, :sheet_name

        delegate :blank?, to: :value

        def initialize(row:, col:, value:, label:, sheet_name:)
          @row = row
          @col = col
          @value = value
          @label = label
          @sheet_name = sheet_name
        end

        def data
          {
            [label, "row"].join("_") => row,
            [label, "col"].join("_") => col,
            label => value,
            "sheet_name" => sheet_name
          }
        end
      end
    end
  end
end
