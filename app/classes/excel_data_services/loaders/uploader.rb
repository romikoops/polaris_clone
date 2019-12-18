# frozen_string_literal: true

require './lib/roo/excelx_money'

module ExcelDataServices
  module Loaders
    class Uploader < ExcelDataServices::Loaders::Base
      VALID_EXCEL_MIME_SUBTYPES = ['x-ole-storage',
                                   'vnd.ms-excel',
                                   'vnd.openxmlformats-officedocument.spreadsheetml.sheet'].freeze

      VALIDATION_FLAVORS = ['Missing Values',
                            'Insertable Checks',
                            'Smart Assumptions'].freeze

      def initialize(tenant:, file_or_path:, options: {})
        super(tenant: tenant)
        @file_or_path = file_or_path
        @options = options
      end

      def perform # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        result_insertion_stats = {}
        data_restructurer_names_for_all_sheets = {}
        headers_for_all_sheets = {}

        xlsx = open_spreadsheet_file(file_or_path)
        # Header validation and data restructurer names
        xlsx.each_with_pagename do |sheet_name, sheet_data|
          first_row = sheet_data.first_row
          next unless first_row

          headers = parse_headers(sheet_data.row(first_row))
          header_validator = ExcelDataServices::Validators::HeaderChecker.new(sheet_name, headers)
          header_validator.perform
          return header_validator.errors_obj unless header_validator.valid?

          headers_for_all_sheets[sheet_name] = headers
          data_restructurer_names_for_all_sheets[sheet_name] = header_validator.data_restructurer_name
        end

        # Raw parsing
        all_sheets_raw_data = parse_data(xlsx, headers_for_all_sheets, data_restructurer_names_for_all_sheets)

        all_sheets_raw_data.each do |per_sheet_raw_data|
          # Restructure individual sheet data
          data_by_insertion_type = restructure_data(per_sheet_raw_data)

          # Per sheet there might be different insertion types (e.g. 'Pricing' and 'LocalCharges')
          data_by_insertion_type.each do |insertion_type, data_part|
            insertion_type = insertion_type.to_s

            # Validate data per insertion type
            VALIDATION_FLAVORS.each do |flavor|
              validator_klass = ExcelDataServices::Validators::Base.get(flavor, insertion_type)
              validator = validator_klass.new(tenant: tenant, data: data_part)
              validator.perform
              return validator.errors_obj unless validator.valid?
            end

            # Insert into database
            partial_insertion_stats = insert_into_database(insertion_type, data_part)
            result_insertion_stats = combine_stats(result_insertion_stats, partial_insertion_stats)
          end
        end

        result_insertion_stats
      end

      private

      attr_reader :file_or_path, :options

      def open_spreadsheet_file(file_or_path)
        path = Pathname(file_or_path).to_s

        raise ExcelDataServices::Validators::ValidationErrors::UnsupportedFiletype unless valid_excel?(path)

        Roo::ExcelxMoney.new(path)
      end

      def valid_excel?(path)
        # Try binary first, then file extension
        mime_subtype = MimeMagic.by_magic(File.open(path))&.subtype
        mime_subtype = MimeMagic.by_path(path).subtype if mime_subtype == 'zip'

        return false unless mime_subtype

        VALID_EXCEL_MIME_SUBTYPES.any? { |valid_subtype| valid_subtype.include?(mime_subtype) }
      end

      def parse_headers(header_row)
        header_row.map! do |el|
          next :'' if el.nil?

          el.downcase!
          el.gsub!(%r{[^a-z0-9\/\-\_\(\)]+}, '_') # underscore instead of unwanted characters
          el.to_sym
        end
      end

      def parse_data(xlsx, headers_for_all_sheets, data_restructurer_names_for_all_sheets)
        file_parser = ExcelDataServices::FileParser
        file_parser.parse(tenant: tenant,
                          xlsx: xlsx,
                          headers_for_all_sheets: headers_for_all_sheets,
                          data_restructurer_names_for_all_sheets: data_restructurer_names_for_all_sheets)
      end

      def restructure_data(raw_data)
        restructurer = ExcelDataServices::Restructurers::Base
        restructurer.restructure(tenant: tenant, data: raw_data)
      end

      def insert_into_database(insertion_type, data)
        inserter = ExcelDataServices::Inserters::Base.get(insertion_type)
        inserter.insert(tenant: tenant, data: data, options: options)
      end

      def combine_stats(hsh_1, hsh_2)
        hsh_1.deep_merge(hsh_2) { |_key, val_1, val_2| val_1 + val_2 }
      end
    end
  end
end
