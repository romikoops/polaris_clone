# frozen_string_literal: true

module ExcelDataServices
  module Loaders
    class Downloader < Base
      def initialize(tenant:, specific_identifier:, file_name:, sandbox:, group_id: nil)
        super(tenant: tenant)
        @specific_identifier = specific_identifier
        @file_name = file_name
        @sandbox = sandbox
        @group_id = group_id
      end

      def perform
        file_writer = ExcelDataServices::FileWriters.const_get(specific_identifier)
        options = { tenant: tenant, file_name: file_name, sandbox: sandbox }
        file_writer.write_document(options)
      end

      private

      attr_reader :specific_identifier, :file_name, :sandbox
    end
  end
end
