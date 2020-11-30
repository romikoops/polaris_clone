# frozen_string_literal: true

require "doorkeeper"
require "onelogin/ruby-saml"

module IDP
  class Engine < ::Rails::Engine
    isolate_namespace IDP

    config.generators do |generator|
      generator.orm false
      generator.fixture_replacement false
      generator.test_framework :rspec
      generator.assets false
      generator.helper false
      generator.javascripts false
      generator.model_specs false
      generator.stylesheets false
      generator.view_specs false
    end

    initializer "idp.automount" do |app|
      app.routes.prepend do
        mount IDP::Engine, at: "/"
      end
    end

    initializer "idp.inflections" do |app|
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.acronym "IDP"
      end
    end
  end
end
