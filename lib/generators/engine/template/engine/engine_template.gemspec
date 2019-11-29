# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'engine_template'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['GITUSER_NAME']
  s.email       = ['GITUSER_EMAIL']
  s.summary     = 'Summary of EngineTemplate.'

  # Uncomment line below to mark this component to be directly required by app.
  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'core'

  Gemhelper.common_gems(s)
end
