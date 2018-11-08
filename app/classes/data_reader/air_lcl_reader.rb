# frozen_string_literal: true

module DataReader
  class AirLclReader < BaseReader
    private

    def validate_headers(sheet_name, headers)
      valid_headers = %i(
        effective_date
        expiration_date
        customer_email
        origin
        destination
        carrier
        service_level
        transit_time
        range_min
        range_max
        wm_ratio
        currency
        rate_basis
        rate_min
        rate
        hw_rate_basis
        hw_threshold
      )

      # Order needs to be maintained in order to be valid
      headers_are_valid = headers == valid_headers
      raise StandardError, "The headers of sheet \"#{sheet_name}\" are not valid." unless headers_are_valid
    end

    def build_row_obj(headers, parsed_row)
      headers.zip(parsed_row).to_h
    end
  end
end
