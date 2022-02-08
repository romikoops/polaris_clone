# frozen_string_literal: true

module ExcelDataServices
  module Loaders
    class Uploader
      def initialize(file:, options: {})
        @file = file
        @options = options
      end

      def perform
        return uploader_service.perform if uploader_service.valid?

        legacy_service_result
      end

      private

      attr_reader :file, :options

      def uploader_service
        @uploader_service ||= ExcelDataServices::V2::Upload.new(
          file: file,
          arguments: options.merge({ disabled_uploaders: v2_disabled_uploaders })
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

      def v2_disabled_uploaders
        OrganizationManager::ScopeService.new(
          target: upload.user,
          organization: file.organization
        ).fetch(:v2_uploaders).select { |_, val| val == false }.keys.map(&:camelize)
      end
    end
  end
end
