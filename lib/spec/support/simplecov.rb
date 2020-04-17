# frozen_string_literal: true

require 'simplecov'

SimpleCov.configure do
  # Customised Rails Profile
  load_profile 'test_frameworks'

  add_filter %r{/config/}
  add_filter %r{/db/}
  add_filter %r{^/vendor/ruby}
  add_filter %r{^/lib/generators/}

  add_group 'Controllers', 'app/controllers'
  add_group 'Channels', 'app/channels'
  add_group 'Models', 'app/models'
  add_group 'Mailers', 'app/mailers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Jobs', %w[app/jobs app/workers]
  add_group 'Libraries', 'lib/'

  track_files '{app,lib}/**/*.rb'

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
