# frozen_string_literal: true

module DataReader
  class OceanFclReader < DataReader::BaseReader
    VALUE_TO_SPLIT_HEADERS_AFTER = :currency

    private

    def post_initialize
    end

    def build_row_obj(headers, row_data)
      row = parse_row_data(row_data)

      # Seperate the fees into their own hash and nest them into result
      ## Split headers and rows
      standard_headers, fee_headers = headers.slice_after(VALUE_TO_SPLIT_HEADERS_AFTER).to_a
      split_index = standard_headers.length
      row_until_fees = row[0...split_index]
      row_just_fees = row[split_index..-1]

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
