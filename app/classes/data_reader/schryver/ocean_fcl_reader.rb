# frozen_string_literal: true

module DataReader
  module Schryver
    class OceanFclReader < DataReader::BaseReader
      private

      DYNAMIC_FEE_COLS_NO_RANGES_HEADERS = %i(effective_date
                                              expiration_date
                                              customer_email
                                              origin
                                              country_origin
                                              destination
                                              country_destination
                                              mot
                                              carrier
                                              service_level
                                              load_type
                                              type
                                              transit_time
                                              currency).freeze

      ONE_COL_FEE_AND_RANGES_HEADERS = %i(effective_date
                                          expiration_date
                                          customer_email
                                          origin
                                          country_origin
                                          destination
                                          country_destination
                                          mot
                                          carrier
                                          service_level
                                          load_type
                                          type
                                          range_min
                                          range_max
                                          currency
                                          fee_code
                                          fee_name
                                          fee).freeze

      def determine_data_extraction_method(headers)
        @data_extraction_method = if headers.include?(:fee_code)
                                    'one_col_fee_and_ranges'
                                  else
                                    'dynamic_fee_cols_no_ranges'
                                  end
      end

      def headers_valid?(headers)
        valid_static_headers = case data_extraction_method
                               when 'dynamic_fee_cols_no_ranges'
                                 DYNAMIC_FEE_COLS_NO_RANGES_HEADERS
                               when 'one_col_fee_and_ranges'
                                 ONE_COL_FEE_AND_RANGES_HEADERS
                               else
                                 [nil]
                               end

        # Order needs to be maintained in order to be valid
        valid_static_headers.each_with_index.map { |el, i| el == headers[i] }.all?
      end

      def restructure_with_dynamic_fee_cols_no_ranges(rows_data)
        rows_data.map do |row_data|
          # Put fees one level deeper under :fees key
          standard_keys, fee_keys = row_data.keys.slice_after(:currency).to_a
          standard_part = row_data.slice(*standard_keys)
          fee_part = row_data.slice(*fee_keys)

          standard_part.merge(fees: fee_part)
        end
      end

      def restructure_with_one_col_fee_and_ranges(rows_data)
        rows_data.map do |row_data|
          if row_data[:range_min] && row_data[:range_max]
            # TODO!!!!!!!
          else
            row_data
          end
        end
      end

      def restructure_rows_data(rows_data)
        case data_extraction_method
        when 'dynamic_fee_cols_no_ranges'
          restructure_with_dynamic_fee_cols_no_ranges(rows_data)
        when 'one_col_fee_and_ranges'
          restructure_with_one_col_fee_and_ranges(rows_data)
        else
          []
        end
      end
    end
  end
end
