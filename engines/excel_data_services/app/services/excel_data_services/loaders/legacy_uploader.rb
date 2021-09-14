# frozen_string_literal: true

require "./lib/roo/excelx_money"

module ExcelDataServices
  module Loaders
    class LegacyUploader < ExcelDataServices::Loaders::Base
      VALID_EXCEL_MIME_SUBTYPES = ["x-ole-storage",
        "vnd.ms-excel",
        "vnd.openxmlformats-officedocument.spreadsheetml.sheet"].freeze

      VALIDATION_FLAVORS = ["Missing Values",
        "Insertable Checks",
        "Smart Assumptions"].freeze

      def initialize(organization:, file_or_path:, options: {})
        super(organization: organization)
        @file_or_path = file_or_path
        @options = options
      end

      def perform
        result_insertion_stats = {}
        restructurer_names_for_all_sheets = {}
        headers_for_all_sheets = {}
        Organizations::Organization.current_id = organization.id
        path = Pathname(file_or_path).to_s
        return { has_errors: true, errors: invalid_file_type_error } unless valid_excel_filetype?(path)

        xlsx = open_spreadsheet_file(path)

        # intercept upload process here for new schema/library based inserter
        file = ExcelDataServices::Schemas::Detector.detect(xlsx: xlsx)
        return ExcelDataServices::DataFrames::Runners::Blocks.run(file: file, arguments: runner_options) if file.present?

        # Header validation and data restructurer names
        header_errors = []
        xlsx.each_with_pagename do |sheet_name, sheet_data|
          first_row = sheet_data.first_row
          next unless first_row

          headers = parse_headers(sheet_data.row(first_row))
          header_validator = ExcelDataServices::Validators::HeaderChecker.new(sheet_name, headers)
          header_validator.perform
          header_errors << header_validator.results(filter: :error) unless header_validator.valid?

          headers_for_all_sheets[sheet_name] = headers
          restructurer_names_for_all_sheets[sheet_name] = header_validator.restructurer_name
        end

        return { has_errors: true, errors: header_errors.flatten } if header_errors.present?

        all_sheets_raw_data = parse_data(xlsx, headers_for_all_sheets, restructurer_names_for_all_sheets)

        type_errors = []
        all_sheets_raw_data.each do |sheet|
          type_validator = ExcelDataServices::Validators::TypeValidity::Base.get(sheet[:restructurer_name])
          type_errors << type_validator.new(sheet: sheet).type_errors
        end

        return { has_errors: true, errors: type_errors.flatten } if type_errors.flatten.any?

        validation_errors = []
        restructured_data =
          all_sheets_raw_data.each_with_object({}) do |per_sheet_raw_data, hsh|
            hsh[per_sheet_raw_data[:sheet_name]] = restructure_data(per_sheet_raw_data) if per_sheet_raw_data[:rows_data].present?
          end

        restructured_data.each do |sheet_name, data_by_insertion_types|
          data_by_insertion_types.each do |insertion_type, data_part|
            VALIDATION_FLAVORS.each do |flavor|
              validator_klass = ExcelDataServices::Validators::Base.get(flavor, insertion_type.to_s)
              validator = validator_klass.new(organization: organization,
                                              sheet_name: sheet_name,
                                              data: data_part,
                                              options: options)
              validator.perform
              validation_errors << validator.results(filter: :error) unless validator.valid?
            end
          end
        end

        return { has_errors: true, errors: validation_errors.flatten } if validation_errors.present?

        restructured_data.each do |_sheet_name, data_by_insertion_types|
          data_by_insertion_types.each do |insertion_type, data_part|
            partial_insertion_stats = insert_into_database(insertion_type, data_part)
            result_insertion_stats = combine_stats(result_insertion_stats, partial_insertion_stats)
          end
        end

        result_insertion_stats
      end

      private

      attr_reader :file_or_path, :options

      def open_spreadsheet_file(path)
        Roo::ExcelxMoney.new(path)
      end

      def invalid_file_type_error
        [{
          type: :error,
          row_nr: 1,
          sheet_name: "",
          reason: "The file uploaded was of an unsupported file type. Please use .xlsx or .xls filetypes.",
          exception_class: ExcelDataServices::Validators::ValidationErrors::UnsupportedFiletype
        }]
      end

      def valid_excel_filetype?(path)
        # Try binary first, then file extension
        mime_type = MimeMagic.by_magic(File.open(path)) || MimeMagic.by_path(path)
        mime_subtype = mime_type.subtype if mime_type.present?
        return false if mime_subtype.nil?

        VALID_EXCEL_MIME_SUBTYPES.any? { |valid_subtype| valid_subtype.include?(mime_subtype) }
      end

      def parse_headers(header_row)
        header_row.map! do |el|
          next :'' if el.nil?

          el = el.to_s
          el.downcase!
          el.gsub!(%r{[^a-z0-9/\-_()]+}, "_") # underscore instead of unwanted characters
          el.to_sym
        end
      end

      def parse_data(xlsx, headers_for_all_sheets, restructurer_names_for_all_sheets)
        file_parser = ExcelDataServices::FileParser
        file_parser.parse(organization: organization,
                          xlsx: xlsx,
                          headers_for_all_sheets: headers_for_all_sheets,
                          restructurer_names_for_all_sheets: restructurer_names_for_all_sheets)
      end

      def restructure_data(raw_data)
        restructurer = ExcelDataServices::Restructurers::Base
        restructurer.restructure(organization: organization, data: raw_data)
      end

      def insert_into_database(insertion_type, data)
        inserter = ExcelDataServices::Inserters::Base.get(insertion_type)
        # rubocop:disable Rails/SkipsModelValidations
        inserter.insert(organization: organization, data: data, options: options)
        # rubocop:enable Rails/SkipsModelValidations
      end

      def combine_stats(stats, partial_stats)
        stats.deep_merge(partial_stats) { |_key, val1, val2| val1 + val2 }
      end
    end
  end
end
