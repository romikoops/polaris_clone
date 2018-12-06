# frozen_string_literal: true

module ExcelDataServices
  module FileWriter
    class AirLcl < Base
      include PricingRowDataBuilder

      private

      def load_and_prepare_data
        pricings = tenant.pricings.for_mode_of_transport('air').for_cargo_class('lcl')
        raw_pricing_rows = build_raw_pricing_rows(pricings)
        rows_data_static_fee_col = build_rows_data_with_static_fee_col(raw_pricing_rows)

        { 'Sheet1': rows_data_static_fee_col }
      end
    end
  end
end
