# frozen_string_literal: true

module ExcelDataServices
  module FileParser
    class Base
      HubNotFoundError = Class.new(StandardError)
      InvalidHeadersError = Class.new(ParsingError)
      UnknownSheetNameError = Class.new(ParsingError)

      attr_reader :tenant, :xlsx, :sheets_data

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

          validate_headers(headers, sheet_name, data_extraction_method)

          # Parse all but first row
          rows_data = []
          raw_rows_without_headers(sheet_data).each do |row_nr|
            row_data = build_row_obj(headers, sheet_data.row(row_nr))
            rows_data << row_data.merge(row_nr: row_nr)
          end

          @sheets_data[sheet_name][:rows_data] = rows_data
        end

        @sheets_data = restructure_data(@sheets_data)
        @errors = ExcelDataServices::FileParser::DataValidator::Pricing.validate_data(@sheets_data, @tenant)
        return { has_errors: true, errors: @errors } unless @errors.empty?

        @sheets_data
      end

      private

      def open_spreadsheet_file(file_or_path)
        file_or_path = Pathname(file_or_path).to_s
        Roo::Spreadsheet.open(file_or_path)
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

      def build_valid_headers
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      def validate_headers(headers, sheet_name, data_extraction_method)
        valid_headers = build_valid_headers(data_extraction_method)
        passing_headers = valid_headers.select.with_index { |el, i| el == headers[i] }
        failing_headers_indices = valid_headers.each_with_object([]).with_index do |(el, indices), i|
          indices << i if el != headers[i]
        end
        failing_headers = headers.values_at(*failing_headers_indices)
        failing_headers_sould_be = valid_headers - passing_headers

        unless failing_headers.blank?
          raise InvalidHeadersError, "The following headers of sheet \"#{sheet_name}\" are not valid:\n" \
                                     "IS       : \"#{failing_headers.join(', ')}\",\n" \
                                     "SHOULD BE: \"#{failing_headers_sould_be.join(', ')}\""
        end

        true
      end

      def raw_rows_without_headers(sheet_data)
        ((sheet_data.first_row + 1)..sheet_data.last_row)
      end

      def strip_whitespaces(row_data)
        row_data.each_with_object({}) do |(k, v), hsh|
          hsh[k] = v.is_a?(String) ? v.strip : v
        end
      end

      def sanitize_row_data(row_data)
        strip_whitespaces(row_data)
      end

      def build_row_obj(headers, row)
        row_data = headers.zip(row).to_h
        sanitize_row_data(row_data)
      end

      def restructure_data(_data)
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      def append_hub_suffix(name, mot)
        name + ' ' + case mot
                     when 'ocean' then 'Port'
                     when 'air'   then 'Airport'
                     when 'rail'  then 'Railyard'
                     when 'truck' then 'Depot'
                     end
      end
    end
  end
end
