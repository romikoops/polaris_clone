# frozen_string_literal: true

module UserServices
  class Engine < ::Rails::Engine
    isolate_namespace UserServices

    config.generators do |generator|
      generator.test_framework      :rspec
      generator.assets              false
      generator.helper              false
      generator.javascripts         false
      generator.model_specs         false
      generator.stylesheets         false
      generator.view_specs          false
    end

    config.factory_bot.definition_file_paths += [File.expand_path("../../factories", __dir__)] if defined?(FactoryBotRails)
  end
end
