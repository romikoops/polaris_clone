# frozen_string_literal: true

require 'bundler/setup'

require 'simplecov'
SimpleCov.start do
  minimum_coverage 98 unless ENV['SKIP_COVERAGE']

  if ENV['COVERAGE_DIR']
    command_name 'lib/charge_calculator'
    coverage_dir(ENV['COVERAGE_DIR'])
    merge_timeout 3600
  end

  if ENV['CI']
    require 'simplecov-cobertura'
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
    formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::CoberturaFormatter,
                                                         SimpleCov::Formatter::LcovFormatter
                                                       ])
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
