# frozen_string_literal: true

module ExcelDataServices
  module Loaders
    class Uploader
      UPLOAD_VERSIONS = %w[v3 v4].freeze

      def initialize(file:, options: {})
        @file = file
        @options = options
      end

      def perform
        return valid_uploader_service.perform if valid_uploader_service.present?

        legacy_service_result
      end

      private

      attr_reader :file, :options

      def valid_uploader_service
        UPLOAD_VERSIONS.map { |version| uploader_service(version: version) }.find(&:valid?)
      end

      def uploader_service(version:)
        "ExcelDataServices::#{version.upcase}::Upload".constantize.new(
          file: file,
          arguments: options.merge({ disabled_uploaders: disabled_uploaders(version: version) })
        )
      end

      def legacy_service_result
        Processor.new(blob: file.file.blob).process do |raw_file|
          ExcelDataServices::Loaders::LegacyUploader.new(
            organization: file.organization,
            file_or_path: raw_file,
            options: options.merge({ user: upload.user })
          ).perform
        end
      end

      def upload
        @upload ||= ExcelDataServices::Upload.find_by(file: file)
      end

      def disabled_uploaders(version:)
        scope[:uploaders].reject { |_, val| val == version }.keys.map(&:camelize)
      end

      def scope
        @scope ||= OrganizationManager::ScopeService.new(
          target: upload.user,
          organization: file.organization
        ).fetch
      end
    end
  end
end
