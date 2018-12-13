# frozen_string_literal: true

module ExcelDataServices
  module FileParser
    class OceanFcl < Base
      include ExcelDataServices::PricingTool
      include DataRestructurer::Pricing

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
          raise InvalidDataExtractionMethodError, 'Unknown data extraction method!'
        end
      end
    end
  end
end
