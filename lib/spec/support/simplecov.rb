# frozen_string_literal: true

require 'simplecov'

SimpleCov.configure do
  load_profile 'rails'
  add_filter 'vendor/ruby'
  add_filter(%r{^/lib/generators/}) # For Generators

  if ENV['COVERAGE_DIR']
    coverage_dir(ENV['COVERAGE_DIR'])
    merge_timeout 3600
  end

  if ENV['CI']
    require 'simplecov-cobertura'
    require 'simplecov-workspace-lcov'

    SimpleCov::Formatter::WorkspaceLcovFormatter.config.report_with_single_file = true
    SimpleCov::Formatter::WorkspaceLcovFormatter.config.workspace_path = ENV['WORKSPACE_ROOT']
    formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::CoberturaFormatter,
                                                         SimpleCov::Formatter::WorkspaceLcovFormatter
                                                       ])
  end
end
