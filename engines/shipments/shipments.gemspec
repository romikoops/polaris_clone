# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-shipments'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = <<~SUMMARY
    The Shipments Engine is responsible for handling the data level of shipment requests and shipments
  SUMMARY

  s.metadata = { 'type' => 'service' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  # External gems
  s.add_dependency 'aasm'
  s.add_dependency 'money-rails', '~> 1.12'

  # Internal engines
  s.add_dependency 'imc-address_book'
  s.add_dependency 'imc-cargo'
  s.add_dependency 'imc-core'
  s.add_dependency 'imc-quotations'
  s.add_dependency 'imc-routing'
  s.add_dependency 'imc-sequential'
  s.add_dependency 'imc-organizations'

  Gemhelper.common(s)
end
