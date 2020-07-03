# frozen_string_literal: true

require 'bitfields'
require 'routing'
require 'organizations'

module TenantRouting
  class Engine < ::Rails::Engine
    isolate_namespace TenantRouting

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
  end
end
