# frozen_string_literal: true

require "config"
require "google_sign_in"

module AdmiraltyAuth
  class Engine < ::Rails::Engine
    isolate_namespace AdmiraltyAuth

    config.generators do |g|
      g.orm                 :active_record, primary_key_type: :uuid
      g.fixture_replacement :factory_bot, dir: 'factories'
      g.test_framework      :rspec
      g.assets              false
      g.helper              false
      g.javascripts         false
      g.model_specs         false
      g.stylesheets         false
      g.view_specs          false
    end
  end
end
