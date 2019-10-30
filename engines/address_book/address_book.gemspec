# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'address_book'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Bassam Aziz']
  s.email       = ['bassam.aziz@itsmycargo.com']
  s.summary     = 'This engine is used to work with addresses and contacts for shipments.
                   eg: consignee, consignor, notifyees.'

  # Uncomment line below to mark this component to be directly required by app.
  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'core'
  s.add_dependency 'tenants'

  s.add_dependency 'geocoder'
  s.add_dependency 'pg_search'

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
