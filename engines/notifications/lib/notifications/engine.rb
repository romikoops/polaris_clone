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

    if defined?(FactoryBotRails)
      config.factory_bot.definition_file_paths << File.expand_path("../../factories", __dir__)
    end

    initializer :assets do |app|
      app.config.assets.precompile += %w[notifications/logo-blue.png]
    end

    initializer :event do |app|
      config.to_prepare do
        Rails.configuration.event_store.subscribe(AdminUserCreatedJob, to: [Users::UserCreated])
        Rails.configuration.event_store.subscribe(UserCreatedJob, to: [Users::UserCreated])

        # Offer created notifications
        Rails.configuration.event_store.subscribe(OfferCreated::AdminNotifierJob, to: [Journey::OfferCreated])
        Rails.configuration.event_store.subscribe(ShipmentRequestCreatedJob, to: [Journey::ShipmentRequestCreated])
        Rails.configuration.event_store.subscribe(RequestCreatedJob, to: [Journey::RequestCreated])
      end
    end
  end
end
