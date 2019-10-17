# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'api'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Mikko Kokkonen']
  s.email       = ['mikko.kokkonen@itsmycargo.com']
  s.summary     = 'Summary of Api.'

  # Uncomment line below to mark this component to be directly required by app.
  s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'api_auth'
  s.add_dependency 'core'
  s.add_dependency 'tenants'
  s.add_dependency 'trucking'

  s.add_dependency 'active_model_serializers', '~> 0.10', '>= 0.10.8'

  s.add_development_dependency 'api_docs'

  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec_api_documentation', '5.1.0'
  s.add_development_dependency 'rspec_junit_formatter'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-cobertura'
end
