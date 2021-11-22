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

          value_from_cell(cell: cell)
        end
      end

      def column(col_number)
        first_row.upto(last_row).map do |row|
          cell = cells[[row, col_number]]

          next if cell&.value.blank?

          value_from_cell(cell: cell)
        end
      end

      private

      def value_from_cell(cell:)
        cell_value = cell.value
        return cell_value unless cell_value.is_a?(Numeric) || (cell_value.is_a?(String) && cell_value.match(/\d/))

        currency_descr = extract_currency(cell)
        extracted_value = extract_value(cell_value)

        return cell_value unless currency_descr && Money::Currency.table[currency_descr.downcase.to_sym].present?

        parse_to_money(currency_descr, extracted_value)
      end

      def extract_currency(cell)
        captures = if (cell_format = cell.format)
          cell_format.scan(/\[\$([^+\-\d]+)\]/).flatten
        elsif cell.value
          cell.value.strip.scan(/^-?(?:\d+(?:\.\d*)?|\.\d+)[[:space:]][A-Z]{3}$|^[A-Z]{3}[[:space:]]-?(?:\d+(?:\.\d*)?|\.\d+)$/)
        end

        return if captures.empty?

        captures.first[/[A-Z]{3}/]
      end

      def parse_to_money(currency_descr, cell_value)
        Monetize.parse("#{currency_descr} #{cell_value.to_f}", "no-fallback-currency", assume_from_symbol: true)
      end

      def extract_value(cell_value)
        cell_value.is_a?(Numeric) ? cell_value : cell_value[/-?(?:\d+(?:\.\d*)?|\.\d+)/]
      end
    end
  end
end
