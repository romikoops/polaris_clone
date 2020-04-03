# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-analytics'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = <<~SUMMARY
    Analytics service engine for pulling in and manipulating data for use
    in the Bridge analytics page
  SUMMARY

  s.metadata = { 'type' => 'service' }

  s.add_dependency 'imc-legacy'
  s.add_dependency 'imc-pricings'
  s.add_dependency 'imc-quotations'
  s.add_dependency 'imc-shipments'
  s.add_dependency 'imc-tenants'

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  Gemhelper.common(s)
end
