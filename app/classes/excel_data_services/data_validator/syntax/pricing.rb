# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Syntax
      class Pricing < Base
        include ExcelDataServices::PricingTool

        def perform
          super do |row|
            # raise NotImplementedError
          end
        end

        private

        def build_valid_headers(data_extraction_method)
          case data_extraction_method
          when 'dynamic_fee_cols_no_ranges'
            DYNAMIC_FEE_COLS_NO_RANGES_HEADERS
          when 'one_col_fee_and_ranges'
            ONE_COL_FEE_AND_RANGES_HEADERS
          end
        end
      end
    end
  end
end
