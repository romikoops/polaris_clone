# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'admiralty_tenants'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Mikko Kokkonen']
  s.email       = ['mikko.kokkonen@itsmycargo.com']
  s.summary     = 'Summary of AdmiraltyTenants.'

  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'admiralty_assets'
  s.add_dependency 'admiralty_auth'
  s.add_dependency 'core'
  s.add_dependency 'legacy'
  s.add_dependency 'tenants'

  s.add_dependency 'jsoneditor-rails'
  s.add_dependency 'rails', '~> 5.2.1'

  Gemhelper.common_gems(s)
end
