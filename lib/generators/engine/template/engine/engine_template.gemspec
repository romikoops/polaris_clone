# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'engine_template/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'engine_template'
  s.version     = '0.0.1'
  s.authors     = ['GITUSER_NAME']
  s.email       = ['GITUSER_EMAIL']
  s.summary     = 'Summary of EngineTemplate.'

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'rails', '~> 5.2.1'

  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'pg', '~> 0.17'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec_junit_formatter'
  s.add_development_dependency 'simplecov'
end
