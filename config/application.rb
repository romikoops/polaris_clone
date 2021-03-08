# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Polaris
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.active_record.schema_format = :sql
    config.active_record.dump_schemas = :all

    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Flash
    config.middleware.use ActionDispatch::Session::CookieStore, key: "_imc_platform_session"

    # Committee
    if Rails.root.join("doc", "api", "swagger.json").exist?
      error_handler = -> (ex, env) {
        application = nil
        if env["HTTP_AUTHORIZATION"]
          _, token = env["HTTP_AUTHORIZATION"].split
          application = token.application.name if (token = Doorkeeper::AccessToken.find_by(token: token))
        end

        Sentry.capture_exception(ex, extra: { rack_env: env }, tags: {application: application})
      }

      config.middleware.use Committee::Middleware::RequestValidation,
        schema_path: "doc/api/swagger.json",
        coerce_date_times: true,
        ignore_error: true,
        parse_response_by_content_type: false,
        error_handler: error_handler
      config.middleware.use Committee::Middleware::ResponseValidation,
        schema_path: "doc/api/swagger.json",
        coerce_date_times: true,
        ignore_error: true,
        parse_response_by_content_type: false,
        error_handler: error_handler
    end

    config.skylight.environments << "review"
    config.skylight.probes << "active_job"
    config.skylight.probes << "active_model_serializers"
    config.skylight.probes << "redis"

    config.i18n.available_locales = %w[en de]
  end
end
