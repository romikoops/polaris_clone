# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-api_docs'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Provides internal API documentation.'

  s.metadata = { 'type' => 'view' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'

  s.add_dependency 'raddocs'

  s.add_development_dependency 'rspec_api_documentation'

  Gemhelper.common(s)
end
