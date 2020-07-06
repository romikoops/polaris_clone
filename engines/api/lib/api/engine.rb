# frozen_string_literal: true

require 'api_auth'
require 'cargo'
require 'core'
require 'pricings'
require 'profiles'
require 'organizations'
require 'users'
require 'trucking'
require 'wheelhouse'

require 'draper'
require 'fast_jsonapi'
require 'kaminari'

module Api
  class Engine < ::Rails::Engine
    isolate_namespace Api

    config.autoload_paths << File.expand_path('../../app', __dir__)

    config.active_record.primary_key = :uuid

    config.generators do |g|
      g.orm                 :active_record, primary_key_type: :uuid
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.test_framework      :rspec
      g.assets              false
      g.helper              false
      g.javascripts         false
      g.model_specs         false
      g.stylesheets         false
      g.view_specs          false
    end

    initializer 'json_api', after: 'active_model_serializers.set_configs' do
      ActiveModelSerializers.config.adapter = :json_api
      ActiveModelSerializers.config.key_transform = :camel_lower
    end

    initializer :append_migrations do |app|
      config.paths['db/migrate'].expanded.each do |expanded_path|
        app.config.paths['db/migrate'] << expanded_path
      end
    end

    if defined?(FactoryBot)
      initializer 'model_core.factories', after: 'factory_bot.set_factory_paths' do
        FactoryBot.definition_file_paths << Pathname.new(File.expand_path('../../spec/factories', __dir__))
      end
    end

    initializer :kaminari do
      Kaminari.configure do |config|
        config.page_method_name = :paginate_api
      end
    end
  end
end
