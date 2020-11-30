# frozen_string_literal: true

require "draper"
require "write_xlsx"

module Wheelhouse
  class Engine < ::Rails::Engine
    isolate_namespace Wheelhouse

    config.generators do |generator|
      generator.test_framework :rspec
      generator.assets false
      generator.helper false
      generator.javascripts false
      generator.model_specs false
      generator.stylesheets false
      generator.view_specs false
    end
  end
end
