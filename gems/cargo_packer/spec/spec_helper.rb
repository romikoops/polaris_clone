# frozen_string_literal: true

require "bundler/setup"
require "factory_bot_rails"

require "simplecov"
SimpleCov.start do
  enable_coverage :branch

  if ENV["CI"]
    require "simplecov-cobertura"

    formatter SimpleCov::Formatter::CoberturaFormatter
  end
end

require "cargo_packer"
require "webmock/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.include FactoryBot::Syntax::Methods
  FactoryBot.definition_file_paths = %w[factories]
  FactoryBot.find_definitions
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  if ENV["CI"]
    require "rspec_junit_formatter"
    config.add_formatter(RspecJunitFormatter, File.expand_path("../junit.xml", __dir__))
  else
    config.add_formatter("doc")
  end
end
