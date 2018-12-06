# frozen_string_literal: true

module ExcelDataServices
  module FileWriter
    class OceanFcl < Base
      include PricingRowDataBuilder

      private

      DYNAMIC_FEE_COLS_NO_RANGES_ATTRIBUTES_LOOKUP = STATIC_HEADERS_ATTRIBUTES_LOOKUP.merge(
        transit_time: :transit_time
      ).freeze

      def load_and_prepare_data
        pricings = tenant.pricings.for_mode_of_transport('ocean').all_fcl
        raw_pricing_rows = build_raw_pricing_rows(pricings)

        dynamic_headers = raw_pricing_rows.map { |x| x[:shipping_type]&.downcase&.to_sym }.uniq.compact.sort
        data_with_dynamic_headers, data_static_fee_col = raw_pricing_rows.group_by { |row| row[:range].blank? }.values

        rows_data_with_dynamic_headers = build_rows_data_with_dynamic_headers(data_with_dynamic_headers, dynamic_headers)
        rows_data_static_fee_col = build_rows_data_with_static_fee_col(data_static_fee_col)

        { 'No Ranges': rows_data_with_dynamic_headers,
          'With Ranges': rows_data_static_fee_col }
      end

      def build_rows_data_with_dynamic_headers(data_with_dynamic_headers, dynamic_headers)
        return nil unless data_with_dynamic_headers && dynamic_headers

        sort!(data_with_dynamic_headers)
        data_with_dynamic_headers.map do |attributes|
          row_data = {}

          DYNAMIC_FEE_COLS_NO_RANGES_ATTRIBUTES_LOOKUP.each do |key, value|
            row_data.merge!(key => attributes[value])
          end

          # Fill all dynamic headers with nil
          dynamic_headers.each do |key|
            row_data.merge!(key => nil)
          end

          # Overwrite the one existing dynamic header with the correct value
          header = attributes[:shipping_type]&.downcase&.to_sym
          row_data[header] = attributes[:rate]

          row_data
        end
      end
    end
  end
end
