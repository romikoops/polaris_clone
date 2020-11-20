# frozen_string_literal: true

require "draper"
require "write_xlsx"

module Wheelhouse
  class Engine < ::Rails::Engine
    isolate_namespace Wheelhouse

    config.generators do |g|
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
