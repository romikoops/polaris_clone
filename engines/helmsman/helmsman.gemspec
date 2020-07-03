# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-helmsman'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Validating possible routes for tenant.'

  s.metadata = { 'type' => 'service' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-federation'
  s.add_dependency 'imc-ledger'
  s.add_dependency 'imc-routing'
  s.add_dependency 'imc-tenant_routing'
  s.add_dependency 'imc-organizations'
  s.add_dependency 'imc-organization_manager'

  s.add_development_dependency 'imc-companies'
  s.add_development_dependency 'imc-legacy'

  Gemhelper.common(s)
end
