# frozen_string_literal: true

module Admiralty
  class Engine < ::Rails::Engine
    isolate_namespace Admiralty

    config.generators do |g|
      g.orm                 false
      g.test_framework      :rspec
      g.assets              false
      g.helper              false
      g.javascripts         false
      g.model_specs         false
      g.stylesheets         false
      g.view_specs          false
    end

    initializer "admiralty.automount" do |app|
      app.routes.prepend do
        mount Admiralty::Engine, at: "/admiralty"
      end
    end
  end
end
