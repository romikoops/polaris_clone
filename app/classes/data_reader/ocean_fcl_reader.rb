# frozen_string_literal: true

module DataReader
  class OceanFclReader < DataReader::BaseReader
    private

    def post_initialize
    end

    def validate_headers(headers, sheet_name)
      valid_headers = %i(
        effective_date
        expiration_date
        customer_email
        origin
        destination
        mot
        carrier
        service_level
        load_type
        transit_time
        currency
      )

      # Order needs to be maintained in order to be valid
      headers_are_valid = valid_headers.each_with_index.map { |el, i| el == headers[i] }.all?
      raise StandardError, "The headers of sheet \"#{sheet_name}\" are not valid." unless headers_are_valid
    end

    def build_row_obj(headers, parsed_row)
      # Seperate the fees into their own hash and nest them into result
      ## Split headers and rows
      standard_headers, fee_headers = headers.slice_after(:currency).to_a
      split_index = standard_headers.length
      row_until_fees = parsed_row[0...split_index]
      row_just_fees = parsed_row[split_index..-1]

      ## Build hash objects, and merge them
      standard_part = standard_headers.zip(row_until_fees).to_h
      fee_part = { fees: fee_headers.zip(row_just_fees).to_h }
      standard_part.merge(fee_part)
    end

    def local_stats
      {}
    end
  end
end
