# frozen_string_literal: true

module ExcelDataServices
  class UploaderJob < ApplicationJob
    queue_as :default

    def perform(upload_id:, options:)
      upload = ExcelDataServices::Upload.find(upload_id)
      document = upload.file
      organization = document.organization
      Organizations.current_id = organization.id
      user = upload.user

      set_sentry_context(document, user)

      email_wrapper = EmailWrapper.new(organization: organization, user: user, document: document)

      if document.created_at < latest_created_at(organization: organization, doc_type: document.doc_type)
        update_status!(upload: upload, status: "superseded")
        email_wrapper.enqueue_email(result: document_superseded_result(document: document), bcc: ["ops@itsmycargo.com"])

        return
      end

      update_status!(upload: upload, status: "processing")
      result = ExcelDataServices::Loaders::Uploader.new(
        file: document,
        options: options
      ).perform
      update_status!(upload: upload, status: result[:errors].empty? ? "done" : "failed")
      email_wrapper.enqueue_email(result: result)
      # rubocop:disable Style/RescueStandardError
    rescue => e
      # rubocop:enable Style/RescueStandardError
      Sentry.capture_exception(e)
      update_status!(upload: upload, status: "failed")
      email_wrapper.enqueue_email(result: exception_result(document: document), bcc: ["ops@itsmycargo.com"])
    end

    private

    def set_sentry_context(document, user)
      scope = Sentry.get_current_scope

      scope.set_tags(organization: document.organization.slug)
      scope.set_user(id: user.id, email: user.email)

      scope.set_context(:doc_type, document.doc_type)
      scope.set_context(:file, document.text)
    end

    def update_status!(upload:, status:)
      upload.status = status
      upload.last_job_id = job_id
      upload.save!
    end

    def latest_created_at(organization:, doc_type:)
      Legacy::File
        .where(organization: organization, doc_type: doc_type)
        .order(:created_at)
        .last
        .created_at
    end

    def document_superseded_result(document:)
      {
        has_errors: true,
        errors: [
          {
            sheet_name: document.doc_type,
            reason: <<-STRING.squish
              The creation date of the document that has been attempted
              to be uploaded has been superseded by a newer document.
              This document won't be attempted to be uploaded any longer.
            STRING
          }
        ]
      }
    end

    def exception_result(document:)
      {
        has_errors: true,
        errors: [
          {
            sheet_name: document.doc_type,
            reason: <<-STRING.squish
              We are sorry, but something has gone wrong while inserting your
              #{document.doc_type.humanize} data. The Operations Team has been
              notified of the error.
            STRING
          }
        ]
      }
    end

    class EmailWrapper
      def initialize(organization:, user:, document:, mailer: UploadMailer)
        @organization = organization
        @user = user
        @document = document
        @mailer = mailer
      end

      def enqueue_email(result:, bcc: [])
        mailer
          .with(
            user_id: user.id,
            organization: organization,
            result: JSON.parse(result.to_json),
            file: document.file.blob.filename.sanitized,
            bcc: bcc
          )
          .complete_email
          .deliver_later
      end

      private

      attr_reader :organization, :user, :document, :mailer
    end
  end
end
