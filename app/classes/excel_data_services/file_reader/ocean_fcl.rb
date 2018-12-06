# frozen_string_literal: true

module ExcelDataServices
  module FileReader
    class OceanFcl < Base
      include ExcelDataServices::PricingTool

      private

      def determine_data_extraction_method(headers)
        if headers.include?(:fee_code)
          'one_col_fee_and_ranges'
        else
          'dynamic_fee_cols_no_ranges'
        end
      end

      def build_valid_headers(data_extraction_method)
        case data_extraction_method
        when 'dynamic_fee_cols_no_ranges'
          DYNAMIC_FEE_COLS_NO_RANGES_HEADERS
        when 'one_col_fee_and_ranges'
          ONE_COL_FEE_AND_RANGES_HEADERS
        else
          raise StandardError, 'Unknown data extraction method!'
        end
      end

      def sanitize_rows_data(rows_data)
        rows_data
      end
    end
  end
end
