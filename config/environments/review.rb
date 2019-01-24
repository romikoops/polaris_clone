# frozen_string_literal: true

require_relative './production'

Rails.application.configure do
  config.active_job.queue_adapter = :async

  Mail.register_interceptor(
    RecipientInterceptor.new(
      ENV.fetch('EMAIL_RECIPIENTS', 'development+qa@itsmycargo.com'),
      subject_prefix: ENV.fetch('EMAIL_SUBJECT_PREFIX') { "[REVIEW] (#{ENV['REVIEW_NAME']})" }
    )
  )
end
