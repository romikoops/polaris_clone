# frozen_string_literal: true

module ExcelDataServices
  module FileParser
    class ChargeCategories < Base
      include ExcelDataServices::ChargeCategoryTool
      include DataRestructurer::ChargeCategories

      private

      def build_valid_headers(_data_extraction_method)
        VALID_CHARGE_HEADERS
      end

      def sanitize_row_data(row_data)
        row_data = strip_whitespaces(row_data)
      end
    end
  end
end
