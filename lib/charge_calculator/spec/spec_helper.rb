# frozen_string_literal: true

require 'bundler/setup'

require 'simplecov'
SimpleCov.start do
  minimum_coverage 98

  if ENV['COVERAGE_DIR']
    command_name 'charge_calculator/rspec'
    coverage_dir(ENV['COVERAGE_DIR'])
    merge_timeout 3600
  end
end

require 'charge_calculator'
require 'support/json_schema_matcher'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
