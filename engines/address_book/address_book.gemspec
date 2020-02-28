# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-address_book'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = <<~SUMMARY
    This engine is used to work with addresses and contacts for shipments.
    eg: consignee, consignor, notifyees.
  SUMMARY

  s.metadata = { 'type' => 'data' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-tenants'

  s.add_dependency 'geocoder'
  s.add_dependency 'pg_search'

  Gemhelper.common(s)
end
