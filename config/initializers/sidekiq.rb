# ActiveJob
ActiveJob::TrafficControl.client = ConnectionPool.new(size: 5, timeout: 5) { Redis.new }

# Prometheus
if ENV["PROMETHEUS_EXPORTER"]
  require "prometheus_exporter/instrumentation"

  Sidekiq.configure_server do |config|
    config.on :startup do
      PrometheusExporter::Instrumentation::ActiveRecord.start(
        custom_labels: {type: "sidekiq"},
        config_labels: [:database, :host]
      )
      PrometheusExporter::Instrumentation::Process.start(type: "sidekiq")
      PrometheusExporter::Instrumentation::SidekiqQueue.start
    end

    config.server_middleware do |chain|
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end

    config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler

    at_exit do
      PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
    end
  end
end
