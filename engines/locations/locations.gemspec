# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'locations'
  s.version     = '0.0.1'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Warwick Beamish']
  s.email       = ['wkbeamish@gmail.com']
  s.summary     = 'Summary of Locations.'

  # Uncomment line below to mark this component to be directly required by app.
  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'core'

  s.add_dependency 'elasticsearch', '~> 7.3.0'
  s.add_dependency 'rgeo'
  s.add_dependency 'rgeo-geojson'
  s.add_dependency 'searchkick', '~> 4.1.0'

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
