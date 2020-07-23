# frozen_string_literal: true

require "doorkeeper"
require "onelogin/ruby-saml"
require "rails"

require "authentication"
require "organization_manager"
require "organizations"
require "profiles"

module IDP
  class Engine < ::Rails::Engine
    isolate_namespace IDP

    config.autoload_paths << File.expand_path("../../app", __dir__)

    config.active_record.primary_key = :uuid

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

    initializer "idp.factories", after: "factory_bot.set_factory_paths" do
      if defined?(FactoryBot)
        FactoryBot.definition_file_paths << Pathname.new(File.expand_path("../../spec/factories", __dir__))
      end
    end
  end
end
