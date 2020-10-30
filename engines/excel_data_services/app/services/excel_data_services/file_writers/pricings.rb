# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class Pricings < ExcelDataServices::FileWriters::Base
      private

      def load_and_prepare_data
        result = {}
        raw_pricing_rows = PricingsRowDataBuilder.build_raw_pricing_rows(filtered_pricings)

        if options[:load_type] == "cargo_item"
          data_static_fee_col = raw_pricing_rows
        else
          data_static_fee_col, data_with_dynamic_headers = raw_pricing_rows.partition { |row| row[:range].present? }
          dynamic_headers = build_dynamic_headers(raw_pricing_rows)
          result["No Ranges"] = build_rows_with_dynamic_headers(data_with_dynamic_headers, dynamic_headers)
        end

        result["With Ranges"] = PricingsRowDataBuilder.build_rows_data_with_static_fee_col(data_static_fee_col)

        result.compact
      end

      def filtered_pricings
        pricings = ::Pricings::Pricing.where(organization: organization)
        pricings = pricings.current
        pricings = pricings.where(group_id: options[:group_id]) if options[:group_id]
        pricings = pricings.for_mode_of_transport(options[:mode_of_transport]) if options[:mode_of_transport]
        pricings = pricings.for_load_type(options[:load_type]) if options[:load_type]
        pricings
      end
    end
  end
end
