# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'rms_sync'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Warwick Beamish']
  s.email       = ['wkbeamish@gmail.com']
  s.summary     = 'Summary of RmsSync.'

  # Uncomment line below to mark this component to be directly required by app.
  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'activerecord-import'
  s.add_dependency 'core'
  s.add_dependency 'legacy'
  s.add_dependency 'pricings'
  s.add_dependency 'rms_data'
  s.add_dependency 'routing'
  s.add_dependency 'tenants'

  Gemhelper.common_gems(s)
end
