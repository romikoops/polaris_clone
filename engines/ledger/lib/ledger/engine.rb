# frozen_string_literal: true

module Ledger
  class Engine < ::Rails::Engine
    isolate_namespace Ledger

    config.active_record.primary_key = :uuid

    config.generators do |gen|
      gen.orm                 :active_record, primary_key_type: :uuid
      gen.fixture_replacement :factory_bot, dir: "factories"

      gen.test_framework      :rspec
      gen.assets              false
      gen.helper              false
      gen.javascripts         false
      gen.model_specs         false
      gen.stylesheets         false
      gen.view_specs          false
    end

    initializer :append_migrations do |app|
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end

      DataMigrate.configure do |config|
        config.data_migrations_path << File.expand_path("../../db/data", __dir__)
      end
    end

    config.factory_bot.definition_file_paths += [File.expand_path("../../factories", __dir__)] if defined?(FactoryBotRails)
  end
end
