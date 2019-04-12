# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class OceanLcl < Base
      private

      def load_and_prepare_data
        pricings = tenant.pricings.for_mode_of_transport('ocean').for_cargo_classes(['lcl'])
        raw_pricing_rows = PricingRowDataBuilder.build_raw_pricing_rows(pricings)
        rows_data_static_fee_col = PricingRowDataBuilder.build_rows_data_with_static_fee_col(raw_pricing_rows)

        { 'With Ranges' => rows_data_static_fee_col }
      end

      def build_raw_headers(_sheet_name, _rows_data)
        HEADER_COLLECTION::PRICING_ONE_COL_FEE_AND_RANGES
      end
    end
  end
end
