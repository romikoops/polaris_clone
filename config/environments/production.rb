# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Attempt to read encrypted secrets from `config/secrets.yml.enc`.
  # Requires an encryption key in `ENV["RAILS_MASTER_KEY"]` or
  # `config/secrets.yml.key`.
  config.read_encrypted_secrets = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  config.active_job.queue_adapter = :shoryuken
  config.action_mailer.deliver_later_queue_name = 'https://sqs.eu-central-1.amazonaws.com/003688427525/mailers'
  # config.active_job.queue_name_prefix = "imcr_#{Rails.env}"
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')
  # config.logger = RemoteSyslogLogger.new('logs6.papertrailapp.com', 17326, :program => "rails-production")
  # if ENV["RAILS_LOG_TO_STDOUT"].present?
  #   logger           = ActiveSupport::Logger.new(STDOUT)
  #   logger.formatter = config.log_formatter
  #   config.logger    = ActiveSupport::TaggedLogging.new(logger)
  # end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
if ENV['WORKER_MODE'] == 1
  Raven.configure do |config|
    config.dsn = 'http://6d3b102312b84a62a8f6d982e2676152:79f79cc3abf14a4f94cd84397e28f658@ec2-52-29-81-197.eu-central-1.compute.amazonaws.com/5'
  end
else
  Raven.configure do |config|
    config.dsn = 'http://e38fa6c168f64dec8070b81ba26694cc:2516c99c0be842c99e3b2cc6884f2e99@ec2-52-29-81-197.eu-central-1.compute.amazonaws.com/3'
    # config.environments = ['staging', 'production']
  end
end
