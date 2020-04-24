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

  if ENV['CONTINUOUS_INTEGRATION']
    coverage_dir 'coverage'
    merge_timeout 3600

    require 'simplecov-cobertura'

    formatter SimpleCov::Formatter::CoberturaFormatter
  end
end
