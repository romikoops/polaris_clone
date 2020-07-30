# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-wheelhouse'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = <<~SUMMARY
    This engine houses logic that proxies internal quotations to the offer
    calculator engine
  SUMMARY

  s.metadata = { 'type' => 'service' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-cargo'
  s.add_dependency 'imc-core'
  s.add_dependency 'imc-legacy'
  s.add_dependency 'imc-offer_calculator'
  s.add_dependency 'imc-pdf'
  s.add_dependency 'imc-organizations'
  s.add_dependency 'imc-organization_manager'

  s.add_dependency 'draper', '~> 4.0'
  s.add_dependency 'write_xlsx'

  Gemhelper.common(s)
end
