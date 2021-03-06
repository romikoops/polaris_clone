# frozen_string_literal: true

require "draper"
require "pdfkit"

module Pdf
  class Engine < ::Rails::Engine
    isolate_namespace Pdf

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
  end
end
