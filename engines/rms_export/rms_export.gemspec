# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'rms_export'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Warwick Beamish']
  s.email       = ['warwick.beamish@itsmycargo.com']
  s.summary     = 'Summary of RmsExport.'

  # Uncomment line below to mark this component to be directly required by app.
  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'core'
  s.add_dependency 'routing'
  s.add_dependency 'write_xlsx'

  Gemhelper.common_gems(s)

  s.add_development_dependency 'legacy'
  s.add_development_dependency 'pricings'
  s.add_development_dependency 'rms_sync'
  s.add_development_dependency 'roo'
  s.add_development_dependency 'roo-xls'
  s.add_development_dependency 'tenants'
  s.add_development_dependency 'tenant_routing'

end
