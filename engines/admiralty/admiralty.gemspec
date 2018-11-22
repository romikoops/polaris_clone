# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'admiralty'
  s.version     = '0.0.1'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Mikko Kokkonen']
  s.email       = ['mikko.kokkonen@itsmycargo.com']
  s.summary     = 'Summary of Admiralty.'

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'admiralty_assets'
  s.add_dependency 'admiralty_auth'
  s.add_dependency 'admiralty_tenants'
  s.add_dependency 'core'

  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec_junit_formatter'
  s.add_development_dependency 'simplecov'
end
