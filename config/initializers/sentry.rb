# frozen_string_literal: true

Sentry.init do |config|
  config.breadcrumbs_logger = [:sentry_logger, :active_support_logger]
  config.release = ENV["RELEASE"]

  config.async = lambda do |event, hint|
    Sentry::SendEventJob.perform_later(event, hint)
  end
end
