# frozen_string_literal: true

module ExcelDataServices
  module FileReader
    class OceanLcl < Base
      include ExcelDataServices::PricingTool
      include DataRestructurer::Pricing

      private

      def build_valid_headers(_data_extraction_method)
        ONE_COL_FEE_AND_RANGES_HEADERS
      end

      def sanitize_rows_data(rows_data)
        rows_data
      end
    end
  end
end
