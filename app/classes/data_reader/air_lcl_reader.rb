# frozen_string_literal: true

module DataReader
  class AirLclReader < BaseReader
    private

    ### As of 28 Nov
    # effective_date
    # expiration_date
    # customer_email
    # origin
    # country_origin
    # destination
    # country_destination
    # mot
    # carrier
    # service_level
    # load_type
    # rate_basis
    # currency
    # range_min
    # range_max
    # fee_code
    # fee_name
    # fee


    def headers_valid?(_sheet_name, headers)
      valid_static_headers = %i(effective_date
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
                                hw_threshold)

      valid_static_headers == headers
    end

    def build_row_obj(headers, parsed_row)
      headers.zip(parsed_row).to_h
    end
  end
end
