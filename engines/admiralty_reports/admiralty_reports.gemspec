# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'admiralty_reports'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Henry Perschk']
  s.email       = ['henry.perschk@itsmycargo.com']
  s.summary     = 'Summary of AdmiraltyReports.'

  # Uncomment line below to mark this component to be directly required by app.
  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'admiralty_assets'
  s.add_dependency 'admiralty_auth'
  s.add_dependency 'axlsx'
  s.add_dependency 'axlsx_rails'
  s.add_dependency 'core'
  s.add_dependency 'rubyzip'
  s.add_dependency 'tenants'

  s.add_development_dependency 'roo'
  Gemhelper.common_gems(s)
end
