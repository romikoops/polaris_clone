# frozen_string_literal: true

RSpec.configure do |config|
  config.include Rails.application.routes.url_helpers
end

Rails.application.routes.default_url_options[:host] = 'test.host'
