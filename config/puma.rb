# frozen_string_literal: true

threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads threads_count, threads_count

port ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "development")
plugin :tmp_restart

if ENV["ENABLE_CLOUDWATCH"]
  ENV["PUMA_CLOUDWATCH_DIMENSION_NAME"] = "Environment"
  ENV["PUMA_CLOUDWATCH_DIMENSION_VALUE"] = ENV.fetch("RAILS_ENV", "development").capitalize
  ENV["PUMA_CLOUDWATCH_ENABLED"] = "true"

  activate_control_app
  plugin :cloudwatch
end
