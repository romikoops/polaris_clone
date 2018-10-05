# frozen_string_literal: true

module DataReader
  class LocalChargesReader < DataReader::BaseReader
    private

    def post_initialize
    end

    def validate_headers(headers, sheet_name)
      valid_headers = %i()

      # Order needs to be maintained in order to be valid
      headers_are_valid = headers == valid_headers
      raise StandardError, "The headers of sheet \"#{sheet_name}\" are not valid." unless headers_are_valid
    end

    def build_row_obj(headers, parsed_row)
    end

    def local_stats
      {}
    end
  end
end
