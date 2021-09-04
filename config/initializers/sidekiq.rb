# frozen_string_literal: true

require "sidekiq-status/web"
require "sidekiq/cloudwatchmetrics"
require "sidekiq/cron/web"

# ActiveJob
ActiveJob::TrafficControl.client = ConnectionPool.new(size: 5, timeout: 5) { Redis.new }

Sidekiq.configure_server do |config|
  config.on :startup do
    SidekiqLiveness.start
  end
end

if ENV["ENABLE_CLOUDWATCH"]
  Sidekiq::CloudWatchMetrics.enable!(additional_dimensions: { Environment: Rails.env })
end
