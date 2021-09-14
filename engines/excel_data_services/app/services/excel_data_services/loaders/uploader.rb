# frozen_string_literal: true

module ExcelDataServices
  module Loaders
    class Uploader
      def initialize(file:, options: {})
        @file = file
        @options = options
      end

      def perform
        return uploader_service.perform if v2_enabled? && uploader_service.valid?

        legacy_service_result
      end

      private

      attr_reader :file, :options

      def uploader_service
        @uploader_service ||= ExcelDataServices::V2::Upload.new(
          file: file,
          arguments: options
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

      def v2_enabled?
        OrganizationManager::ScopeService.new(target: upload.user, organization: file.organization).fetch(:upload_v2_enabled)
      end
    end
  end
end
