# frozen_string_literal: true

require "active_model_serializers"
require "draper"
require "fast_jsonapi"
require "kaminari"
require "money_cache"

module Api
  class Engine < ::Rails::Engine
    isolate_namespace Api

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

    initializer "api.automount" do |app|
      app.routes.prepend do
        mount Api::Engine, at: "/"
      end
    end

    initializer "json_api", after: "active_model_serializers.set_configs" do
      ActiveModelSerializers.config.adapter = :json_api
      ActiveModelSerializers.config.key_transform = :camel_lower
    end

    initializer :kaminari do
      Kaminari.configure do |config|
        config.page_method_name = :paginate_api
      end
    end
  end
end
