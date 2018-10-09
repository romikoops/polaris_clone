# frozen_string_literal: true

module DataWriter
  class OceanLclWriter < DataWriter::BaseWriter
    private

    def post_initialize
    end

    def local_stats
      {}
    end

    def extract_raw_headers(first_row)
      first_row.keys
    end

    def extract_row(row_data)
      row_data.values
    end
  end
end
