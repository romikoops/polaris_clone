# frozen_string_literal: true

require "forwardable"
require "monetize"

module Roo
  class ExcelxMoney
    class Sheet < ::Roo::Excelx::Sheet
      def row(row_number)
        first_column.upto(last_column).map do |col|
          cell = cells[[row_number, col]]
          next if cell&.value.blank?

          ValueFromCell.new(cell: cell).perform
        end
      end

      def column(col_number)
        first_row.upto(last_row).map do |row|
          cell = cells[[row, col_number]]

          next if cell&.value.blank?

          ValueFromCell.new(cell: cell).perform
        end
      end
    end
  end
end
require_relative "value_from_cell"