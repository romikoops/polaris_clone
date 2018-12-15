# frozen_string_literal: true

Raven.configure do |config|
  config.dsn = Settings.sentry.dsn
  config.environments = %w(review staging production)
  config.processors -= [Raven::Processor::PostData] # Send POST data
  config.processors -= [Raven::Processor::Cookies] # Send cookies by default

  config.tags = {
    namespace: ENV['REVIEW_NAME']
  }
end
