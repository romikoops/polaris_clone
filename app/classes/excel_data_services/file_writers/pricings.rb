# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class Pricings < ExcelDataServices::FileWriters::Base
      private

      def load_and_prepare_data
        result = {}
        raw_pricing_rows = PricingsRowDataBuilder.build_raw_pricing_rows(filtered_pricings, scope)

        data_with_dynamic_headers, data_static_fee_col = raw_pricing_rows.partition { |row| row[:range].blank? }
        result['With Ranges'] = PricingsRowDataBuilder.build_rows_data_with_static_fee_col(data_static_fee_col)
        dynamic_headers = build_dynamic_headers(raw_pricing_rows)
        result['No Ranges'] = build_rows_with_dynamic_headers(data_with_dynamic_headers, dynamic_headers)

        result.compact
      end

      def filtered_pricings
        pricings = scope['base_pricing'] ? tenant.rates : tenant.pricings
        pricings = pricings.where(sandbox: @sandbox)
        pricings = pricings.where(group_id: options[:group_id]) if options[:group_id]
        pricings = pricings.for_mode_of_transport(options[:mode_of_transport]) if options[:mode_of_transport]
        pricings = pricings.for_load_type(options[:load_type]) if options[:load_type]
        pricings
      end
    end
  end
end
