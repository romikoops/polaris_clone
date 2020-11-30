# frozen_string_literal: true

require "mjml-rails"
require "sorcery"

module Authentication
  class Engine < ::Rails::Engine
    isolate_namespace Authentication

    config.generators do |generator|
      generator.orm :active_record, primary_key_type: :uuid
      generator.fixture_replacement :factory_bot, dir: "spec/factories"
      generator.test_framework :rspec
      generator.assets false
      generator.helper false
      generator.javascripts false
      generator.model_specs false
      generator.stylesheets false
      generator.view_specs false
    end

    if defined?(FactoryBotRails)
      config.factory_bot.definition_file_paths += [File.expand_path("../../factories", __dir__)]
    end
  end
end
