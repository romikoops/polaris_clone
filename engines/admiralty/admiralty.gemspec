# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-admiralty'
  s.version     = '1'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Mikko Kokkonen']
  s.email       = ['mikko.kokkonen@itsmycargo.com']
  s.summary     = <<~SUMMARY
    This engine provides super-admin view for managing tenants and accessing
    financial reports.
  SUMMARY

  s.metadata = { 'type' => 'view', 'direct' => 'true' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-admiralty_assets'
  s.add_dependency 'imc-admiralty_auth'
  s.add_dependency 'imc-admiralty_reports'
  s.add_dependency 'imc-admiralty_tenants'
  s.add_dependency 'imc-core'
  s.add_dependency 'imc-legacy'
  s.add_dependency 'imc-quotations'
  s.add_dependency 'imc-shipments'
  s.add_dependency 'imc-tenants'

  Gemhelper.common(s)
end
