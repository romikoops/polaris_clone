# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Conditions
      class Base
        attr_reader :sheet, :rows, :cols

        def initialize(sheet:, rows:, cols:)
          @sheet = sheet
          @rows = rows
          @cols = cols
        end

        def valid?
          rows.product(cols).any? { |row, col| cell_value_exists(row: row, col: col) }
        end

        private

        def cell_value_exists(row:, col:)
          sheet.cell(row, col).present?
        end
      end
    end
  end
end
