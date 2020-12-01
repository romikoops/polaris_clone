# frozen_string_literal: true

cors_origins = (Settings.cors.origins ? Regexp.new("\\A#{Settings.cors.origins}\\z") : "*")

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins cors_origins
    resource "*", headers: :any, expose: %w[access-token expiry token-type uid client],
                  methods: %i[get post patch put delete options]
  end
end
