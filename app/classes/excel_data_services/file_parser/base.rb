# frozen_string_literal: true

module ExcelDataServices
  module FileParser
    class Base
      def self.parse(options)
        new(options).perform
      end

      def initialize(tenant:, file_or_path:)
        @tenant = tenant
        @xlsx = open_spreadsheet_file(file_or_path)
        @sheets_data = {}
      end

      def perform
        @xlsx.each_with_pagename do |sheet_name, sheet_data|
          first_row_index = sheet_data.first_row
          next unless first_row_index

          headers = parse_headers(sheet_data.row(first_row_index))
          data_extraction_method = determine_data_extraction_method(headers)
          @sheets_data[sheet_name] = { data_extraction_method: data_extraction_method }

          # Parse all but first row
          rows_data = []
          raw_rows_without_headers(sheet_data).each do |row_nr|
            row_data = build_row_obj(headers, sheet_data.row(row_nr))
            rows_data << row_data.merge(row_nr: row_nr)
          end

          @sheets_data[sheet_name][:rows_data] = rows_data
        end

        sheets_data
      end

      private

      attr_reader :tenant, :xlsx, :sheets_data

      def open_spreadsheet_file(file_or_path)
        file_or_path = Pathname(file_or_path).to_s
        Roo::Spreadsheet.open(file_or_path)
      end

      def determine_data_extraction_method(headers)
        if headers.include?(:fee_code)
          'one_col_fee_and_ranges'
        else
          'dynamic_fee_cols_no_ranges'
        end
      end

      def parse_headers(header_row)
        header_row.map! do |el|
          el.downcase!
          el.gsub!(%r{[^a-z0-9\-\/\_]+}, '_') # underscore instead of unwanted characters
          el.to_sym
        end
      end

      def raw_rows_without_headers(sheet_data)
        ((sheet_data.first_row + 1)..sheet_data.last_row)
      end

      def strip_whitespaces(row_data)
        row_data.each_with_object({}) do |(k, v), hsh|
          hsh[k] = v.respond_to?(:strip) ? v.strip : v
        end
      end

      def sanitize_row_data(row_data)
        strip_whitespaces(row_data)
      end

      def parse_dates(row_data)
        unless row_data[:effective_date].is_a?(Date) || row_data[:effective_date].nil?
          row_data[:effective_date] = Date.parse(row_data[:effective_date])
        end
        unless row_data[:expiration_date].is_a?(Date) || row_data[:expiration_date].nil?
          row_data[:expiration_date] = Date.parse(row_data[:expiration_date])
        end

        row_data
      end

      def build_row_obj(headers, row)
        row_data = headers.zip(row).to_h
        row_data = sanitize_row_data(row_data)
        parse_dates(row_data)
      end
    end
  end
end
