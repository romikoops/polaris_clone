# frozen_string_literal: true

module ExcelDataServices
  module FileWriter
    class OceanLcl < Base
      include ExcelDataServices::PricingTool
      include PricingRowDataBuilder

      private

      def load_and_prepare_data
        pricings = tenant.pricings.for_mode_of_transport('ocean').for_cargo_class('lcl')
        raw_pricing_rows = build_raw_pricing_rows(pricings)
        rows_data_static_fee_col = build_rows_data_with_static_fee_col(raw_pricing_rows)

        { 'Sheet1' => rows_data_static_fee_col }
      end

      def build_raw_headers(_sheet_name, _rows_data)
        ONE_COL_FEE_AND_RANGES_HEADERS
      end
    end
  end
end
