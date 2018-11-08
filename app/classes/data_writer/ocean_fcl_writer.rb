# frozen_string_literal: true

module DataWriter
  class OceanFclWriter < BaseWriter
    private

    def extract_raw_headers(first_row)
      fee_headers = first_row[:fees].keys
      other_headers = first_row.keys.reject { |key| key == :fees }
      other_headers + fee_headers
    end

    def extract_row(row_data)
      fee_values = row_data[:fees].values
      other_values = row_data.except(:fees).values
      other_values + fee_values
    end
  end
end
