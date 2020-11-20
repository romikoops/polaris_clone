# frozen_string_literal: true

require "axlsx"
require "axlsx_rails"
require "zip"

module AdmiraltyReports
  class Engine < ::Rails::Engine
    isolate_namespace AdmiraltyReports

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.fixture_replacement :factory_bot, dir: "factories"
      g.test_framework :rspec
      g.assets false
      g.helper false
      g.javascripts false
      g.model_specs false
      g.stylesheets false
      g.view_specs false
    end
  end
end
