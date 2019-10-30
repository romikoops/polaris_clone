# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class RailFcl < Base
      private

      def load_and_prepare_data
        pricing_association = if scope['base_pricing']
                                tenant.rates.where(sandbox: @sandbox, group_id: @group_id)
                              else
                                tenant.pricings.where(sandbox: @sandbox)
                              end
        pricings = pricing_association.for_mode_of_transport('rail').for_cargo_classes(Container::CARGO_CLASSES)
        raw_pricing_rows = PricingRowDataBuilder.build_raw_pricing_rows(pricings, scope)
        dynamic_headers = build_dynamic_headers(raw_pricing_rows)
        data_with_dynamic_headers, data_static_fee_col = raw_pricing_rows.group_by { |row| row[:range].blank? }.values

        rows_with_dynamic_headers = build_rows_with_dynamic_headers(data_with_dynamic_headers, dynamic_headers)
        rows_data_static_fee_col = PricingRowDataBuilder.build_rows_data_with_static_fee_col(data_static_fee_col)

        { 'No Ranges' => rows_with_dynamic_headers,
          'With Ranges' => rows_data_static_fee_col }
      end
    end
  end
end
