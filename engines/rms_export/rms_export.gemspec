# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-rms_export'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'RMS - Export rates to Phoenix'

  s.metadata = { 'type' => 'service' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-organizations'
  s.add_dependency 'imc-organization_manager'
  s.add_dependency 'imc-routing'

  s.add_dependency 'write_xlsx'

  s.add_development_dependency 'roo'
  s.add_development_dependency 'roo-xls'

  Gemhelper.common(s)
end
