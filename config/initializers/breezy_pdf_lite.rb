# frozen_string_literal: true

BreezyPDFLite.setup do |config|
  config.secret_api_key = Settings.breezy.secret
  config.base_url = Settings.breezy.url
end
