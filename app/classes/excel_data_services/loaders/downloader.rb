# frozen_string_literal: true

module ExcelDataServices
  module Loaders
    class Downloader < Base
      def initialize(tenant:, specific_identifier:, file_name:)
        super(tenant: tenant)
        @specific_identifier = specific_identifier
        @file_name = file_name
      end

      def perform
        file_writer = ExcelDataServices::FileWriters.const_get(specific_identifier)
        options = { tenant: tenant, file_name: file_name }
        file_writer.write_document(options)
      end

      private

      attr_reader :specific_identifier, :file_name
    end
  end
end
