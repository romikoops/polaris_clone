# frozen_string_literal: true

module Admiralty
  class Engine < ::Rails::Engine
    isolate_namespace Admiralty

    config.generators do |generator|
      generator.orm false
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
  end
end
