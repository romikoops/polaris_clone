# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-helmsman'
  s.version     = '1'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Warwick Beamish']
  s.email       = ['warwick.beamish@itsmycargo.com']
  s.summary     = 'Validating possible routes for tenant.'

  s.metadata = { 'type' => 'services' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-federation'
  s.add_dependency 'imc-ledger'
  s.add_dependency 'imc-routing'
  s.add_dependency 'imc-tenant_routing'
  s.add_dependency 'imc-tenants'

  Gemhelper.common(s)
end
