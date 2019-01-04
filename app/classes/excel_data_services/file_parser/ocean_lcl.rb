# frozen_string_literal: true

module ExcelDataServices
  module FileParser
    class OceanLcl < Base
      include ExcelDataServices::PricingTool
      include DataRestructurer::Pricing

      private

      def build_valid_headers(_data_extraction_method)
        ONE_COL_FEE_AND_RANGES_HEADERS
      end
    end
  end
end
