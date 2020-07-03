# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-validator'
  s.version     = '1'
  s.license     = 'PROPRIETARY'
  s.authors     = ['ItsMyCargo ApS']
  s.email       = ['mikko.kokkonen@itsmycargo.com']
  s.summary     = <<~SUMMARY
    Validator takes an itinerary and checks each part of the journey for
    matching TenantVehicles, valid Pricings and available Schedules
  SUMMARY

  s.metadata = { 'type' => 'service' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-groups'
  s.add_dependency 'imc-legacy'
  s.add_dependency 'imc-pricings'
  s.add_dependency 'imc-organizations'
  s.add_dependency 'imc-organization_manager'
  s.add_dependency 'imc-trucking'

  Gemhelper.common(s)
end
