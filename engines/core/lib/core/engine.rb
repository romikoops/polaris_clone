# frozen_string_literal: true

require 'activerecord-postgis-adapter'
require 'config'
require 'paper_trail'
require 'rails'
require 'strong_migrations'

module Core
  class Engine < ::Rails::Engine
    isolate_namespace Core

    config.autoload_paths << File.expand_path('../../app', __dir__)

    initializer :append_migrations do |app|
      config.paths['db/migrate'].expanded.each do |expanded_path|
        app.config.paths['db/migrate'] << expanded_path
      end
    end
  end
end
