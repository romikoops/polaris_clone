# frozen_string_literal: true

module ExcelDataServices
  class FileParser
    def self.parse(options)
      new(options).perform
    end

    def initialize(organization:, xlsx:, headers_for_all_sheets:, restructurer_names_for_all_sheets:)
      @organization = organization
      @xlsx = xlsx
      @headers_for_all_sheets = headers_for_all_sheets
      @restructurer_names_for_all_sheets = restructurer_names_for_all_sheets
      @sheets_data = []
    end

    def perform
      xlsx.each_with_pagename do |sheet_name, sheet_data|
        next unless sheet_data.first_row

        rows_data = raw_rows_without_headers(sheet_data).map { |row_nr|
          row_data = build_row_obj(headers_for_all_sheets[sheet_name], sheet_data.row(row_nr))
          row_data.merge(row_nr: row_nr)
        }

        @sheets_data << {sheet_name: sheet_name,
                         restructurer_name: restructurer_names_for_all_sheets[sheet_name],
                         rows_data: rows_data}
      end

      sheets_data
    end

    private

    attr_reader :tenant, :xlsx, :headers_for_all_sheets, :restructurer_names_for_all_sheets, :sheets_data

    def raw_rows_without_headers(sheet_data)
      ((sheet_data.first_row + 1)..sheet_data.last_row)
    end

    def build_row_obj(headers, row)
      row_data = headers.zip(row).to_h
      row_data = sanitize_row_data(row_data)
    end

    def sanitize_row_data(row_data)
      strip_whitespaces(row_data)
    end

    def strip_whitespaces(row_data)
      row_data.each_with_object({}) do |(k, v), hsh|
        hsh[k] = v.respond_to?(:strip) ? v.strip : v
      end
    end
  end
end
