# frozen_string_literal: true

require "bootstrap"
require "jquery-rails"

module AdmiraltyAssets
  class Engine < ::Rails::Engine
    isolate_namespace AdmiraltyAssets

    config.generators do |generator|
      generator.test_framework :rspec
      generator.assets false
      generator.helper false
      generator.javascripts false
      generator.model_specs false
      generator.stylesheets false
      generator.view_specs false
    end

    initializer :assets do |app|
      app.config.assets.precompile += %w[admiralty_assets/logo.png]
    end
  end
end
