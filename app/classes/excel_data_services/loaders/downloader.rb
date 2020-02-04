# frozen_string_literal: true

module ExcelDataServices
  module Loaders
    class Downloader < ExcelDataServices::Loaders::Base
      def initialize(tenant:, category_identifier: nil, file_name:, user: nil, sandbox:, options: {})
        super(tenant: tenant)
        @category_identifier = category_identifier
        @file_name = file_name
        @user = user
        @sandbox = sandbox

        @options = options
      end

      def perform
        ExcelDataServices::FileWriters::Base.get(category_identifier).write_document(
          tenant: tenant,
          file_name: file_name,
          user: user,
          sandbox: sandbox,
          options: options
        )
      end

      private

      attr_reader :category_identifier, :file_name, :user, :sandbox, :options
    end
  end
end
