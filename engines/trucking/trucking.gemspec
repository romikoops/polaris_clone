# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-trucking'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Trucking related rates'

  s.metadata = { 'type' => 'service' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-legacy'
  s.add_dependency 'imc-locations'
  s.add_dependency 'imc-organizations'

  s.add_dependency 'geocoder'
  s.add_dependency 'roo'
  s.add_dependency 'roo-xls'
  s.add_dependency 'will_paginate'

  Gemhelper.common(s)
end
