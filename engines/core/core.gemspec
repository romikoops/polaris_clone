# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'core'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Mikko Kokkonen']
  s.email       = ['mikko.kokkonen@itsmycargo.com']
  s.summary     = 'Summary of Core.'

  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'activerecord-postgis-adapter', '5.2.2'
  s.add_dependency 'config', '~> 1.7.1'
  s.add_dependency 'paper_trail', '~> 10.1', '>= 10.1.0'
  s.add_dependency 'pg', '>= 0.18', '< 2.0'
  s.add_dependency 'rails', '5.2.2'
  s.add_dependency 'strong_migrations', '0.4.1'

  # Fix dry-logic issue
  s.add_dependency 'dry-logic', '>= 0.4.2', '< 0.5.0'

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
