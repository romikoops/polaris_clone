# frozen_string_literal: true

require "google_sign_in"
require "trestle"
require "trestle/active_storage"
require "trestle/auth"
require "trestle/rails_event_store"
require "trestle/search"
require "trestle/sidekiq"
require "trestle/jsoneditor"

module Admiralty
  class Engine < ::Rails::Engine
    isolate_namespace Admiralty

    config.generators do |generator|
      generator.orm false
      generator.fixture_replacement :factory_bot, dir: "spec/factories"
      generator.test_framework :rspec
      generator.assets false
      generator.helper false
      generator.javascripts false
      generator.model_specs false
      generator.stylesheets false
      generator.view_specs false
    end

    initializer "admiralty.automount" do |app|
      app.routes.prepend do
        mount Admiralty::Engine, at: "/admiralty"
      end
    end

    initializer "admiralty.assets" do |app|
      app.config.assets.precompile += %w[logo.png]
    end

    config.factory_bot.definition_file_paths += [File.expand_path("../../factories", __dir__)] if defined?(FactoryBotRails)
  end
end
