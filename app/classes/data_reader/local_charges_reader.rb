# frozen_string_literal: true

module DataReader
  class LocalChargesReader < BaseReader
    private

    def validate_headers(sheet_name, headers)
      valid_headers = %i(
        effective_date
        expiration_date
        direction
        mot
        load_type
        counterpart_hub
        carrier
        service_level
        fee
        fee_code
        rate_basis
        rate_step
        currency
        rate
        minimum
        range_min
        range_max
        dangerous
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
