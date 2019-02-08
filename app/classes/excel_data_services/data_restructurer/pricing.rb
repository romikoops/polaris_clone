# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    class Pricing < Base
      def perform
        data.inject({}) do |memo, (k_sheet_name, values)|
          data_extraction_method = values[:data_extraction_method]
          restructured_rows_data = values[:rows_data].map { |row_data| row_data.except(:row_nr) }
          restructured_rows_data = case data_extraction_method
                                   when 'dynamic_fee_cols_no_ranges'
                                     restructure_with_dynamic_fee_cols_no_ranges(restructured_rows_data)
                                   when 'one_col_fee_and_ranges'
                                     restructure_with_one_col_fee_and_ranges(restructured_rows_data)
                                   else
                                     # Default for all
                                     restructure_with_one_col_fee_and_ranges(restructured_rows_data)
                                   end
          memo.merge(k_sheet_name => { data_extraction_method: data_extraction_method, rows_data: restructured_rows_data })
        end
      end

      def restructure_with_dynamic_fee_cols_no_ranges(rows_data)
        # Put fees one level deeper under :fees key
        rows_data.map do |row_data|
          standard_keys, fee_keys = row_data.keys.slice_after(:currency).to_a
          standard_part = row_data.slice(*standard_keys)
          fee_part = row_data.slice(*fee_keys)

          standard_part.merge(fees: fee_part)
        end
      end

      def restructure_with_one_col_fee_and_ranges(rows_data)
        current_row_identifier_values = []
        row_index_to_skip_to = 0

        restructured_rows_data = rows_data.map.with_index do |row_data, i|
          next if i < row_index_to_skip_to

          if row_data[:range_min] && row_data[:range_max]
            row_index_to_skip_to = i
            ranges_values = []

            current_row_identifier_values = row_identifier_values(row_data)

            while row_connected_by_range?(rows_data[row_index_to_skip_to], current_row_identifier_values)
              ranges_values << extract_range_values(rows_data[row_index_to_skip_to])
              row_index_to_skip_to += 1
            end

            row_data.delete(:range_min) # already inside range hash
            row_data.delete(:range_max) # already inside range hash
            row_data.delete(:fee) # already inside range hash, called 'rate'. Yes, it's ridiculous.
            row_data.merge(range: ranges_values.blank? ? nil : ranges_values)
          else # no ranges
            row_data.delete(:range_min)
            row_data.delete(:range_max)
            row_data
          end
        end
        restructured_rows_data.compact
      end

      def row_identifier_values(row_data)
        row_data.values_at(:effective_date,
                           :expiration_date,
                           :customer_email,
                           :origin,
                           :country_origin,
                           :destination,
                           :country_destination,
                           :mot,
                           :carrier,
                           :service_level,
                           :load_type,
                           :rate_basis,
                           :currency)
      end

      def row_connected_by_range?(next_row_data, current_row_identifier_values)
        return false if next_row_data.nil?

        # Next row should have range values, and contain the same identifier values
        (next_row_data[:range_min] && next_row_data[:range_max]) &&
          row_identifier_values(next_row_data) == current_row_identifier_values
      end

      def extract_range_values(row_data)
        { 'max' => row_data[:range_max], 'min' => row_data[:range_min], 'rate' => row_data[:fee] }
      end
    end
  end
end
