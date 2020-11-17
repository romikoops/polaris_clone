# frozen_string_literal: true

require "activerecord-postgis-adapter"
require "config"
require "mimemagic"
require "paper_trail"
require "rails"
require "roo"
require "roo-xls"
require "rover-df"
require "sentry-raven"
require "write_xlsx"

module ExcelDataServices
  class Engine < ::Rails::Engine
    isolate_namespace ExcelDataServices

    config.generators do |g|
      g.test_framework :rspec
      g.assets false
      g.helper false
      g.javascripts false
      g.model_specs false
      g.stylesheets false
      g.view_specs false
    end

    if defined?(FactoryBotRails)
      config.factory_bot.definition_file_paths += [File.expand_path('../../factories', __dir__)]
    end
  end
end
