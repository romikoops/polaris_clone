# frozen_string_literal: true

module DataReader
  class LocalChargesReader < BaseReader
    private

    def headers_valid?(_sheet_name, headers)
      valid_static_headers = %i(effective_date
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
                                dangerous)

      valid_static_headers == headers
    end

    def build_row_obj(headers, parsed_row)
      headers.zip(parsed_row).to_h
    end
  end
end
