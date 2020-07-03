# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-locations'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Provides location information.'

  s.metadata = { 'type' => 'service' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'

  s.add_dependency 'elasticsearch', '~> 7.3.0'
  s.add_dependency 'rgeo'
  s.add_dependency 'rgeo-geojson'
  s.add_dependency 'searchkick', '~> 4.1.0'

  Gemhelper.common(s)
end
