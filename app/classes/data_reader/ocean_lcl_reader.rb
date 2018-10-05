# frozen_string_literal: true

module DataReader
  class OceanLclReader < DataReader::BaseReader
    private

    def post_initialize
    end

    def build_row_obj(headers, row_data)
      row = parse_row_data(row_data)

      headers.zip(row).to_h
    end

    def local_stats
      {}
    end
  end
end
