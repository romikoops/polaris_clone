# frozen_string_literal: true

require "simplecov"

SimpleCov.configure do
  # Customised Rails Profile
  load_profile "test_frameworks"

  if ENV["CI"]
    coverage_dir "coverage"
    merge_timeout 3600

    require "simplecov-cobertura"

    formatter SimpleCov::Formatter::CoberturaFormatter
  end
end
