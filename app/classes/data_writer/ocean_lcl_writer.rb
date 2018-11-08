# frozen_string_literal: true

module DataWriter
  class OceanLclWriter < BaseWriter
    private

    def extract_raw_headers(first_row)
      first_row.keys
    end

    def extract_row(row_data)
      row_data.values
    end
  end
end
