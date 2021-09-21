# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  enable_coverage :branch

  # Customised Rails Profile
  load_profile "test_frameworks"

  add_filter %r{/config/}
  add_filter %r{/db/}
  add_filter %r{^/gems}
  add_filter %r{^/lib/generators/}
  add_filter %r{^/vendor/ruby}
  add_filter %r{^/engines/admiralty/app/admin/}

  add_group "Controllers", "app/controllers"
  add_group "Channels", "app/channels"
  add_group "Models", "app/models"
  add_group "Mailers", "app/mailers"
  add_group "Helpers", "app/helpers"
  add_group "Jobs", %w[app/jobs app/workers]
  add_group "Libraries", "lib/"

  track_files "{app,lib}/**/*.rb"

  if ENV["CI"]
    require "simplecov-cobertura"

    formatter SimpleCov::Formatter::CoberturaFormatter
  end
end

require "factory_bot"
require "rspec/instafail"
require "rspec/retry"
require "timecop"
require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!

  config.add_formatter(RSpec::Instafail)
  if ENV["CI"]
    require "rspec_count_formatter"
    config.add_formatter(RspecCountFormatter)
  else
    config.add_formatter("Fuubar")
    config.fuubar_auto_refresh = true

    require "pry"
    Pry.config.hooks.add_hook(:before_session, :disable_fuubar_auto_refresh) do |_output, _binding, _pry|
      RSpec.configuration.fuubar_auto_refresh = false
    end

    Pry.config.hooks.add_hook(:after_session, :restore_fuubar_auto_refresh) do |_output, _binding, _pry|
      RSpec.configuration.fuubar_auto_refresh = true
    end
  end

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 5

  config.order = :random

  Kernel.srand config.seed

  config.verbose_retry = true
  config.display_try_failure_messages = true
end
