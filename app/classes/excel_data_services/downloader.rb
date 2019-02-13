# frozen_string_literal: true

module ExcelDataServices
  class Downloader
    def initialize(tenant:, specific_identifier:, file_name:)
      @tenant = tenant
      # @klass_identifier = determine_broad_klass_identifier(specific_identifier)
      @klass_identifier = specific_identifier
      @file_name = file_name
    end

    def perform
      file_writer = ExcelDataServices::FileWriter.const_get(klass_identifier)
      options = { tenant: tenant, file_name: file_name }
      file_writer.write_document(options)
    end

    private

    attr_reader :tenant, :klass_identifier, :file_name

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
