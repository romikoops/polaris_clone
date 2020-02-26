# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-admiralty_reports'
  s.version     = '1'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Henry Perschk']
  s.email       = ['henry.perschk@itsmycargo.com']
  s.summary     = 'Provides financal reporting for Admiralty.'

  s.metadata = { 'type' => 'view' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-admiralty_assets'
  s.add_dependency 'imc-admiralty_auth'
  s.add_dependency 'imc-core'
  s.add_dependency 'imc-quotations'
  s.add_dependency 'imc-tenants'

  s.add_dependency 'axlsx'
  s.add_dependency 'axlsx_rails'
  s.add_dependency 'rubyzip'

  s.add_development_dependency 'roo'

  Gemhelper.common(s)
end
