# frozen_string_literal: true

require "activerecord-postgis-adapter"
require "config"
require "mimemagic"
require "paper_trail"
require "rails"
require "roo"
require "roo-xls"
require "rover-df"
require "stackprof"
require "uuidtools"
require "write_xlsx"

require_relative "../roo/excelx_money"

module ExcelDataServices
  class Engine < ::Rails::Engine
    isolate_namespace ExcelDataServices

    config.generators do |generator|
      generator.test_framework :rspec
      generator.assets false
      generator.helper false
      generator.javascripts false
      generator.model_specs false
      generator.stylesheets false
      generator.view_specs false
    end

    initializer :append_migrations do |app|
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end

      DataMigrate.configure do |config|
        config.data_migrations_path << File.expand_path("../../db/data", __dir__)
      end
    end

    config.factory_bot.definition_file_paths += [File.expand_path("../../factories", __dir__)] if defined?(FactoryBotRails)
  end
end
