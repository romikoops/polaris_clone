# frozen_string_literal: true

module ExcelDataServices
  module Loaders
    class Downloader < ExcelDataServices::Loaders::Base
      def initialize(organization:, file_name:, category_identifier: nil, user: nil, options: {})
        super(organization: organization)
        @category_identifier = category_identifier
        @file_name = file_name
        @user = user

        @options = options
      end

      def perform
        ExcelDataServices::FileWriters::Base.get(category_identifier).write_document(
          organization: organization,
          file_name: file_name,
          user: user,
          options: options
        )
      end

      private

      attr_reader :category_identifier, :file_name, :user, :options
    end
  end
end
