# frozen_string_literal: true

require_relative "./production"

Rails.application.configure do
  config.active_job.queue_adapter = :async

  config.active_storage.service = :staging

  Mail.register_interceptor(
    RecipientInterceptor.new(
      ENV.fetch("EMAIL_RECIPIENTS", "development+qa@itsmycargo.com"),
      subject_prefix: ENV.fetch("EMAIL_SUBJECT_PREFIX", "[STAGING]")
    )
  )
end
