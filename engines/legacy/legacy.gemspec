# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'legacy'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Mikko Kokkonen']
  s.email       = ['mikko.kokkonen@itsmycargo.com']
  s.summary     = 'Summary of Legacy.'

  # Uncomment line below to mark this component to be directly required by app.
  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'core'

  s.add_dependency 'devise_token_auth', '~> 0.1.43'
  s.add_dependency 'geocoder'
  s.add_dependency 'paranoia', '~> 2.2'
  s.add_dependency 'pg_search', '~> 2.3.0'

  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec_junit_formatter'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-cobertura'
  s.add_development_dependency 'simplecov-lcov'
end
