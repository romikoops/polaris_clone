# frozen_string_literal: true

module ExcelDataServices
  module FileReader
    class OceanFcl < Base
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
                                              rate_basis
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
                                          rate_basis
                                          range_min
                                          range_max
                                          currency
                                          fee_code
                                          fee_name
                                          fee).freeze

      def determine_data_extraction_method(headers)
        if headers.include?(:fee_code)
          'one_col_fee_and_ranges'
        else
          'dynamic_fee_cols_no_ranges'
        end
      end

      def headers_valid?(headers, data_extraction_method)
        valid_static_headers = case data_extraction_method
                               when 'dynamic_fee_cols_no_ranges'
                                 DYNAMIC_FEE_COLS_NO_RANGES_HEADERS
                               when 'one_col_fee_and_ranges'
                                 ONE_COL_FEE_AND_RANGES_HEADERS
                               else
                                 [nil]
                               end

        # Check up until dynamic (fee) headers
        valid_static_headers.each_with_index.map { |el, i| el == headers[i] }.all?
      end

      def sanitize_rows_data(rows_data)
        rows_data
      end
    end
  end
end
