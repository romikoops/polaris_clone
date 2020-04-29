# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-rate_extractor'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = <<~SUMMARY
    This Engine is responsible for loading all rates and fees and associating them with the targets they apply to, within a quotation
  SUMMARY

  s.metadata = { 'type' => 'service' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-cargo'
  s.add_dependency 'imc-quotations'
  s.add_dependency 'imc-rates'
  s.add_dependency 'imc-routing'
  s.add_dependency 'imc-tenant_routing'

  s.add_dependency 'draper', '~> 4.0'

  Gemhelper.common(s)
end
