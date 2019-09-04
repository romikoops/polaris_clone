# frozen_string_literal: true

require 'forwardable'
require 'monetize'

module Roo
  class ExcelxMoney
    class Sheet < ::Roo::Excelx::Sheet
      def row(row_number)
        first_column.upto(last_column).map do |col|
          cell = cells[[row_number, col]]
          cell_value = cell&.value
          next unless cell_value

          currency_descr = extract_currency(cell&.format)
          money_obj = parse_to_money(currency_descr, cell_value) if currency_descr

          money_obj || cell_value
        end
      end

      private

      def extract_currency(cell_format)
        cell_format&.match(/\[\$([^\+\-\d]+)\]/)&.captures&.first
      end

      def parse_to_money(currency_descr, cell_value)
        Monetize.parse("#{currency_descr} #{cell_value.to_f}", 'no-fallback-currency', assume_from_symbol: true)
      end
    end
  end
end
