# frozen_string_literal: true
if !Rails.env.test? && ENV["PROMETHEUS_EXPORTER"]
  require "prometheus_exporter/middleware"
  require "prometheus_exporter/instrumentation"

  PrometheusExporter::Instrumentation::Process.start(type: "web")

  Rails.application.middleware.unshift PrometheusExporter::Middleware
end
