# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Imcr
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.active_job.queue_adapter = :shoryuken
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_imc_platform_session'
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        # origins 'http://localhost:8080', 'localhost:8080', 'localhost:3001', 'http://localhost:3001', /https:\/\/(.*?)\.itsmycargo\.com/
        resource '*', headers: :any, expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'], methods: %i[get post patch put delete options]
      end
    end

    # Autoloads the validators directory
    config.autoload_paths += %W["#{config.root}/app/validators/"]
  end
end
