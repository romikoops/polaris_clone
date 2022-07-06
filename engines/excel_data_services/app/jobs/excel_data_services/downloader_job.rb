# frozen_string_literal: true

module ExcelDataServices
  class DownloaderJob < ApplicationJob
    queue_as :default

    def perform(organization:, category_identifier:, file_name:, user:, options: {})
      set_sentry_context(organization, file_name, user)
      document = generate_document(organization: organization, category_identifier: category_identifier, file_name: file_name, user: user, options: options)
      Notifications::DownloadMailer
        .with(
          user: user,
          organization: organization,
          result: success_result(document: document),
          file_name: file_name,
          category_identifier: category_identifier,
          bcc: []
        )
        .complete_email
        .deliver_later
    rescue StandardError => e
      Sentry.capture_exception(e)

      Notifications::DownloadMailer
        .with(
          user: user,
          organization: organization,
          result: exception_result(file_name: file_name),
          file_name: file_name,
          category_identifier: category_identifier,
          bcc: ["ops@itsmycargo.com"]
        )
        .complete_email
        .deliver_later
    end

    private

    def generate_document(organization:, category_identifier:, file_name:, user:, options: {})
      if category_identifier == "trucking"
        DocumentService::TruckingWriter.new(options).tap(&:perform).legacy_file
      else
        ExcelDataServices::FileWriters::Base.get(category_identifier).write_document(
          organization: organization,
          file_name: file_name,
          user: user,
          options: options
        )
      end
    end

    def set_sentry_context(organization, file_name, user)
      scope = Sentry.get_current_scope

      scope.set_tags(organization: organization.slug)
      scope.set_user(id: user.id, email: user.email)
      scope.set_context(:file, file_name)
    end

    def success_result(document:)
      {}.tap do |result|
        result[:errors] = []
        result[:document] = document
        result[:can_attach] = document.file.byte_size < 10.megabyte
      end
    end

    def exception_result(file_name:)
      {
        document: nil,
        errors: [
          {
            sheet_name: file_name,
            reason: <<-STRING.squish
                We are sorry, but something has gone wrong while generating file
                #{file_name}. The Operations Team has been
                notified of the error.
            STRING
          }
        ]
      }
    end
  end
end
