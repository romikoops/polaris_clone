# frozen_string_literal: true

module ExcelDataServices
  module FileReader
    class AirLcl < Base
      private

      def headers_valid?(headers, _data_extraction_method)
        valid_static_headers = %i(
          effective_date
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
          currency
          range_min
          range_max
          fee_code
          fee_name
          fee
        )

        valid_static_headers == headers
      end

      def sanitize_rows_data(rows_data)
        rows_data
      end
    end
  end
end
