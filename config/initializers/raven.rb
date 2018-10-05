# frozen_string_literal: true

Raven.configure do |config|
  config.dsn = Settings.sentry.dsn
  config.environments = %w(review staging production)
end
