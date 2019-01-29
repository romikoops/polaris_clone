# frozen_string_literal: true

Mailgun.configure do |config|
  config.api_key = Settings.mailgun.api_key
end
