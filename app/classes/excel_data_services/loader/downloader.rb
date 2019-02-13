# frozen_string_literal: true

module ExcelDataServices
  module Loader
    class Downloader < Base
      def initialize(tenant:, specific_identifier:, file_name:)
        super(tenant: tenant, specific_identifier: specific_identifier)
        @file_name = file_name
      end

      def perform
        file_writer = ExcelDataServices::FileWriter.const_get(klass_identifier)
        options = { tenant: tenant, file_name: file_name }
        file_writer.write_document(options)
      end

      private

      attr_reader :tenant, :klass_identifier, :file_name

      def determine_klass_identifier(specific_identifier)
        specific_identifier
      end
    end
  end
end
