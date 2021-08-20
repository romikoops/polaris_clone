# frozen_string_literal: true

module ExcelDataServices
  class UploaderJob < ApplicationJob
    queue_as :default

    def perform(document_id:, options:)
      document = Legacy::File.find(document_id)
      organization = document.organization
      user = Users::User.find(options[:user_id])
      bcc = []

      set_sentry_context(document, user)

      return if document.created_at < latest_created_at(organization: organization, doc_type: document.doc_type)

      options = {
        organization: document.organization,
        options: options.merge({ user: user })
      }

      result = Processor.new(blob: document.file.blob).process do |file|
        ExcelDataServices::Loaders::Uploader.new(options.merge(file_or_path: file)).perform
      end
      # rubocop:disable Style/RescueStandardError
    rescue => e
      # rubocop:enable Style/RescueStandardError
      Sentry.capture_exception(e)
      result = {
        has_errors: true,
        errors: [
          {
            sheet_name: document.doc_type,
            reason: "We are sorry, but something has gone wrong while inserting your #{document.doc_type.humanize} data. The Operations Team has been notified of the error."
          }
        ]
      }
      bcc = ["ops@itsmycargo.com"]
    ensure
      UploadMailer
        .with(
          user_id: user.id,
          organization: document.organization,
          result: JSON.parse(result.to_json),
          file: document.file.blob.filename.sanitized,
          bcc: bcc
        )
        .complete_email
        .deliver_later
    end

    private

    def set_sentry_context(document, user)
      scope = Sentry.get_current_scope

      scope.set_tags(organization: document.organization.slug)
      scope.set_user(id: user.id, email: user.email)

      scope.set_context(:doc_type, document.doc_type)
      scope.set_context(:file, document.text)
    end

    def latest_created_at(organization:, doc_type:)
      Legacy::File
        .where(organization: organization, doc_type: doc_type)
        .order(:created_at)
        .last
        .created_at
    end

    class Processor
      include ActiveStorage::Downloading

      attr_reader :blob

      def initialize(blob:)
        @blob = blob
      end

      def process
        Tempfile.create(["", blob.filename.extension_with_delimiter]) do |file|
          file.binmode
          file.write(blob.download)
          file.rewind

          yield file
        end
      end
    end
  end
end
