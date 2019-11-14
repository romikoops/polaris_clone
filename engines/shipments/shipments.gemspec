# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'shipments'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Bassam Aziz']
  s.email       = ['bassam.aziz@itsmycargo.com']
  s.summary     = 'The Shipments Engine is responsible for handling the data level of shipment requests and shipments'

  # Uncomment line below to mark this component to be directly required by app.
  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  # External gems
  s.add_dependency 'aasm'
  s.add_dependency 'money-rails', '~>1.12'

  # Internal engines
  s.add_dependency 'address_book'
  s.add_dependency 'cargo'
  s.add_dependency 'core'
  s.add_dependency 'quotations'
  s.add_dependency 'routing'
  s.add_dependency 'sequential'
  s.add_dependency 'tenants'

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
