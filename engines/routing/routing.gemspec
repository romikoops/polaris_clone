# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-routing'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Provides information about routing.'

  s.metadata = { 'type' => 'data' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'activerecord-import'
  s.add_dependency 'bitfields'
  s.add_dependency 'rgeo'
  s.add_dependency 'rgeo-geojson'

  s.add_dependency 'imc-core'

  Gemhelper.common(s)
end
