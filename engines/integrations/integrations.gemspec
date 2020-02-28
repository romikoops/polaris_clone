# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-integrations'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Provides integration with 3rd party systems.'

  s.metadata = { 'type' => 'services' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-profiles'
  s.add_dependency 'imc-shipments'

  s.add_development_dependency 'json-schema'

  Gemhelper.common(s)
end
