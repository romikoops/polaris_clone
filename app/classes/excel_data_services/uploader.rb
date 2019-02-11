# frozen_string_literal: true

module ExcelDataServices
  class Uploader
    def initialize(tenant:, specific_identifier:, file_or_path:)
      @tenant = tenant
      @klass_identifier = determine_broad_klass_identifier(specific_identifier)
      @file_or_path = file_or_path
    end

    def perform
      # File Parser & Sanitizer
      file_parser = ExcelDataServices::FileParser.get(klass_identifier)
      options = { tenant: tenant, file_or_path: file_or_path }
      raw_sheets_data = file_parser.parse(options)

      # Syntax Validator
      syntax_validator = ExcelDataServices::DataValidator.get('Syntax', klass_identifier)
      options = { data: raw_sheets_data, tenant: tenant, klass_identifier: klass_identifier }
      errors = syntax_validator.validate(options)
      return { has_errors: true, errors: errors } unless errors.empty?

      # Data Restructurer
      restructurer = ExcelDataServices::DataRestructurer.get(klass_identifier)
      options = { data: raw_sheets_data, tenant: tenant }
      restructured_sheets_data = restructurer.restructure_data(options)

      # Insertability Validator
      insertability_validator = ExcelDataServices::DataValidator.get('Insertability', klass_identifier)
      options = { data: restructured_sheets_data, tenant: tenant, klass_identifier: klass_identifier }
      errors = insertability_validator.validate(options)
      return { has_errors: true, errors: errors } unless errors.empty?

      # Smart Assumptions Validator
      smart_assumptions_validator = ExcelDataServices::DataValidator.get('Smart Assumptions', klass_identifier)
      options = { data: restructured_sheets_data, tenant: tenant, klass_identifier: klass_identifier }
      errors = smart_assumptions_validator.validate(options)
      return { has_errors: true, errors: errors } unless errors.empty?

      # Database Inserter
      inserter = ExcelDataServices::DatabaseInserter.get(klass_identifier)
      options = { tenant: tenant,
                  data: restructured_sheets_data,
                  klass_identifier: klass_identifier,
                  options: { should_generate_trips: false } }
      inserter.insert(options)

      binding.pry

      # Booking Possible Validator
      # TODO...
    end

    private

    attr_reader :tenant, :klass_identifier, :broad_klass_identifier, :file_or_path

    def determine_broad_klass_identifier(specific_klass_identifier)
      case specific_klass_identifier
      when /(Ocean|Air).*/
        'Pricing'
      when /LocalCharges.*/
        'LocalCharges'
      when /ChargeCategories.*/
        'ChargeCategories'
      end
    end
  end
end
