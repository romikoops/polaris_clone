# frozen_string_literal: true

module ExcelDataServices
  module FileWriter
    class OceanFcl < Base
      include ExcelDataServices::PricingTool
      include PricingRowDataBuilder

      private

      def load_and_prepare_data
        pricings = tenant.pricings.for_mode_of_transport('ocean').for_load_type('container')
        raw_pricing_rows = build_raw_pricing_rows(pricings)

        dynamic_headers = build_dynamic_headers(raw_pricing_rows)
        data_with_dynamic_headers, data_static_fee_col = raw_pricing_rows.group_by { |row| row[:range].blank? }.values

        rows_data_with_dynamic_headers = build_rows_data_with_dynamic_headers(data_with_dynamic_headers, dynamic_headers)
        rows_data_static_fee_col = build_rows_data_with_static_fee_col(data_static_fee_col)

        { 'No Ranges' => rows_data_with_dynamic_headers,
          'With Ranges' => rows_data_static_fee_col }
      end

      def build_dynamic_headers(raw_pricing_rows)
        raw_pricing_rows.map { |row| row[:shipping_type]&.downcase&.to_sym }.uniq.compact.sort
      end

      def merge_grouped_rows(grouped_rows)
        grouped_rows.map do |group|
          group.reduce({}) do |memo, obj|
            # Values that are not nil take precedence
            memo.merge!(obj) { |_key, old_val, new_val| new_val.nil? ? old_val : new_val }
          end
        end
      end

      def group_by_static_headers(data_with_dynamic_headers)
        data_with_dynamic_headers.group_by { |el| el.values_at(*DYNAMIC_FEE_COLS_NO_RANGES_HEADERS) }.values
      end

      def build_rows_data_with_dynamic_headers(data_with_dynamic_headers, dynamic_headers)
        return nil unless data_with_dynamic_headers && dynamic_headers

        sort!(data_with_dynamic_headers)
        unmerged_rows = data_with_dynamic_headers.map do |attributes|
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

        grouped_rows = group_by_static_headers(unmerged_rows)
        merge_grouped_rows(grouped_rows)
      end

      def build_raw_headers(sheet_name, rows_data)
        case sheet_name.to_s
        when 'No Ranges'
          dynamic_headers = rows_data.flat_map(&:keys).compact.uniq - DYNAMIC_FEE_COLS_NO_RANGES_HEADERS
          DYNAMIC_FEE_COLS_NO_RANGES_HEADERS + dynamic_headers
        when 'With Ranges'
          ONE_COL_FEE_AND_RANGES_HEADERS
        else
          raise UnknownSheetNameError, "Unknown sheet name \"#{sheet_name}\"!"
        end
      end
    end
  end
end
