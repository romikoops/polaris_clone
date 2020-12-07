# frozen_string_literal: true

require "date_validator"
require "measured/itsmycargo"
require "measured-rails"
require "rein"

module Journey
  class Engine < ::Rails::Engine
    isolate_namespace Journey

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

      DataMigrate.configure do |config|
        config.data_migrations_path << File.expand_path("../../db/data", __dir__)
      end
    end

    if defined?(FactoryBotRails)
      config.factory_bot.definition_file_paths += [File.expand_path("../../factories", __dir__)]
    end
  end
end
