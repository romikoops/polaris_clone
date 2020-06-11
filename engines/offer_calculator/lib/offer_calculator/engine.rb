# frozen_string_literal: true

require 'core'
require 'legacy'
require 'pricings'
require 'result_formatter'
require 'tenants'
require 'trucking'
require 'quotations'

require 'chronic'
require 'sentry-raven'

module OfferCalculator
  class Engine < ::Rails::Engine
    isolate_namespace OfferCalculator

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
