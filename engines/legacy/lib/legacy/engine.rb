# frozen_string_literal: true

require "active_model_serializers"
require "activerecord-import"
require "activejob/traffic_control"
require "draper"
require "fixer_currency"
require "geocoder"
require "mobility"
require "money-rails"
require "paranoia"
require "pg_search"

module Legacy
  class Engine < ::Rails::Engine
    isolate_namespace Legacy

    config.active_record.primary_key = :uuid

    config.generators do |g|
      g.orm                 :active_record, primary_key_type: :uuid
      g.fixture_replacement :factory_bot, dir: 'factories'
      g.test_framework      :rspec
      g.assets              false
      g.helper              false
      g.javascripts         false
      g.model_specs         false
      g.stylesheets         false
      g.view_specs          false
    end

    initializer :append_migrations do |app|
      config.paths['db/migrate'].expanded.each do |expanded_path|
        app.config.paths['db/migrate'] << expanded_path
      end
    end

    if defined?(FactoryBotRails)
      config.factory_bot.definition_file_paths += [File.expand_path('../../factories', __dir__)]
    end
  end
end
