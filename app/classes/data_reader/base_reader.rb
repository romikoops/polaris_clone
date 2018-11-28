# frozen_string_literal: true

module DataReader
  class BaseReader
    attr_reader :xlsx, :sheets_data

    def initialize(path:)
      @xlsx = open_spreadsheet_file(path)
      @sheets_data = {}
    end

    def perform
      @xlsx.each_with_pagename do |sheet_name, sheet_data|
        headers = parse_headers(sheet_data.first)
        data_extraction_method = determine_data_extraction_method(headers)
        @sheets_data[sheet_name] = { data_extraction_method: data_extraction_method }

        raise StandardError, "The headers of sheet \"#{sheet_name}\" are not valid." unless headers_valid?(headers, data_extraction_method)

        # Parse all but first row
        rows_data = []
        ((sheet_data.first_row + 1)..sheet_data.last_row).each do |row_nr|
          row = stripped_whitespaces(sheet_data.row(row_nr))
          rows_data << build_row_obj(headers, row).merge(row_nr: row_nr)
        end

        @sheets_data[sheet_name][:rows_data] = sanitize_rows_data(rows_data)
      end

      @sheets_data
    end

    private

    def open_spreadsheet_file(path)
      path = path.to_s
      Roo::Spreadsheet.open(path)
    end

    def determine_data_extraction_method(_headers)
    end

    def parse_headers(header_row)
      header_row.map! do |el|
        el.downcase!
        el.gsub!(%r{[^a-z0-9\-\/\_]+}, '_') # underscore instead of unwanted characters
        el.to_sym
      end
    end

    def headers_valid?(_headers)
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def stripped_whitespaces(row_data)
      row_data.map! { |el| el.is_a?(String) ? el.strip : el }
    end

    def build_row_obj(headers, row)
      headers.zip(row).to_h
    end

    def sanitize_rows_data(_rows_data)
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end
  end
end
