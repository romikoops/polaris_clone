# frozen_string_literal: true

module Notes
  class Engine < ::Rails::Engine
    isolate_namespace Notes

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.fixture_replacement :factory_bot, dir: "spec/factories"
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
