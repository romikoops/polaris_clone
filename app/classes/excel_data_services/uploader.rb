# frozen_string_literal: true

module ExcelDataServices
  class Uploader
    def initialize(tenant:, klass_identifier:, file_or_path:)
      @tenant = tenant
      @klass_identifier = klass_identifier
      @file_or_path = file_or_path
    end

    def perform
      # File Parser
      klass = ExcelDataServices::FileParser.const_get(klass_identifier)
      options = { tenant: tenant, file_or_path: file_or_path }
      sheets_data = klass.new(options).perform

      return sheets_data if sheets_data[:errors].present?

      # Database Inserter
      klass = ExcelDataServices::DatabaseInserter.const_get(klass_identifier)
      options = { tenant: tenant,
                  data: sheets_data,
                  options: { should_generate_trips: false } }
      klass.new(options).perform
    end

    private

    attr_reader :tenant, :klass_identifier, :file_or_path
  end
end
