# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-tender_calculator'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = <<~SUMMARY
    Responsible for calculating line items for a tender out of the input fees.
  SUMMARY

  s.metadata = { 'type' => 'service' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-cargo'
  s.add_dependency 'imc-rate_extractor'
  s.add_dependency 'imc-rates'
  s.add_dependency 'imc-tenant_routing'

  s.add_development_dependency 'imc-legacy'

  Gemhelper.common(s)
end
