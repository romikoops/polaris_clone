# frozen_string_literal: true

require "doorkeeper"
require "onelogin/ruby-saml"

module IDP
  class Engine < ::Rails::Engine
    isolate_namespace IDP

    config.generators do |g|
      g.orm false
      g.fixture_replacement false
      g.test_framework :rspec
      g.assets false
      g.helper false
      g.javascripts false
      g.model_specs false
      g.stylesheets false
      g.view_specs false
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
