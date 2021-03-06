# frozen_string_literal: true

# require "users"

module Notifications
  class Engine < ::Rails::Engine
    isolate_namespace Notifications

    config.active_record.primary_key = :uuid

    config.generators do |generator|
      generator.orm :active_record, primary_key_type: :uuid
      generator.fixture_replacement :factory_bot, dir: "factories"

      generator.test_framework :rspec
      generator.assets false
      generator.helper false
      generator.javascripts false
      generator.model_specs false
      generator.stylesheets false
      generator.view_specs false
    end

    initializer :append_migrations do |app|
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end

      DataMigrate.config.data_migrations_path << File.expand_path("../../db/data/", __dir__)
    end

    config.factory_bot.definition_file_paths << File.expand_path("../../factories", __dir__) if defined?(FactoryBotRails)

    initializer :assets do |app|
      app.config.assets.precompile += %w[notifications/logo-blue.png]
    end

    initializer :event do |_app|
      config.to_prepare do
        Notifications::Events::EVENT_JOBS_LOOKUP.each do |event_class, jobs|
          jobs.each do |job|
            Rails.configuration.event_store.subscribe(job, to: [event_class])
          end
        end
      end
    end
  end
end
