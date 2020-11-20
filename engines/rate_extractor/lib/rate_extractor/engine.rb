# frozen_string_literal: true

require "draper"

module RateExtractor
  class Engine < ::Rails::Engine
    isolate_namespace RateExtractor

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.fixture_replacement :factory_bot, dir: "factories"
      g.test_framework :rspec
      g.assets false
      g.helper false
      g.javascripts false
      g.model_specs false
      g.stylesheets false
      g.view_specs false
    end

    if defined?(FactoryBotRails)
      config.factory_bot.definition_file_paths += [File.expand_path("../../factories", __dir__)]
    end
  end
end
