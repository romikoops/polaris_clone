# frozen_string_literal: true

module ExcelDataServices
  class Uploader
    def initialize(tenant:, klass_identifier:, file_or_path:)
      @tenant = tenant
      @klass_identifier = klass_identifier
      @broad_klass_identifier = determine_broad_klass_identifier(klass_identifier)
      @file_or_path = file_or_path
    end

    def perform
      # File Parser & Sanitizer
      file_parser = ExcelDataServices::FileParser.get(klass_identifier)
      options = { tenant: tenant, file_or_path: file_or_path }
      raw_sheets_data = file_parser.parse(options)

      # Syntax Validator
      # TODO...

      # Data Restructurer
      restructurer = ExcelDataServices::DataRestructurer.get(broad_klass_identifier)
      restructured_sheets_data = restructurer.restructure_data(raw_sheets_data)

      # Insertability Validator
      validator = ExcelDataServices::DataValidator::Insertability.get(broad_klass_identifier)
      options = { data: restructured_sheets_data, tenant: tenant }
      errors = validator.validate(options)
      return { has_errors: true, errors: errors } unless errors.empty?

      # Smart Assumptions Validator
      # TODO...

      # Database Inserter
      inserter = ExcelDataServices::DatabaseInserter.get(klass_identifier)
      options = { tenant: tenant,
                  data: restructured_sheets_data,
                  options: { should_generate_trips: false } }
      inserter.insert(options)

      # Booking Possible Validator
      # TODO...
    end

    private

    attr_reader :tenant, :klass_identifier, :broad_klass_identifier, :file_or_path

    def determine_broad_klass_identifier(specific_klass_identifier)
      case specific_klass_identifier
      when /Ocean.+|Air.+/
        'Pricing'
      when /LocalCharges.+/
        'LocalCharges'
      when /ChargeCategories.+/
        'ChargeCategories'
      end
    end
  end
end
