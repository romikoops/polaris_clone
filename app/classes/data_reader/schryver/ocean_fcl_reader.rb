# frozen_string_literal: true

module DataReader
  module Schryver
    class OceanFclReader < DataReader::BaseReader
      private

      def validate_headers(sheet_name, headers)
        valid_static_headers = case sheet_name
                               when 'Rate Sheet'
                                 %i(effective_date
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
                                    currency)
                               when 'Other Charges'
                                 [] # for now, assign something ([]) that makes headers valid.
                               else
                                 [nil]
                               end

        # Order needs to be maintained in order to be valid
        headers_are_valid = valid_static_headers.each_with_index.map { |el, i| el == headers[i] }.all?
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
    end
  end
end
