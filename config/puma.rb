# frozen_string_literal: true

require "prometheus_exporter/instrumentation"

threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
plugin :tmp_restart

if ENV["PROMETHEUS_EXPORTER"]
  after_worker_boot do
    PrometheusExporter::Instrumentation::ActiveRecord.start(
      custom_labels: {type: "puma_single_mode"},
      config_labels: [:database, :host]
    )
    PrometheusExporter::Instrumentation::Puma.start
    PrometheusExporter::Instrumentation::Process.start(type: "web")
  end
end
