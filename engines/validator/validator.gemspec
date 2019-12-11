# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'validator'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Warwick Beamish']
  s.email       = ['warwick.beamish@itsmycargo.com']
  s.summary     = 'Validator takes an itinerary and checks each part of the journey for
  matching TenantVehicles, valid Pricings and available Schedules '

  # Uncomment line below to mark this component to be directly required by app.
  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'core'
  s.add_dependency 'legacy'
  s.add_dependency 'pricings'
  s.add_dependency 'tenants'
  s.add_dependency 'trucking'

  Gemhelper.common_gems(s)
end
