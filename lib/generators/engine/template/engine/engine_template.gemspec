# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-engine_template'
  s.version     = '1'
  s.license     = 'PROPRIETARY'
  s.authors     = ['GITUSER_NAME']
  s.email       = ['GITUSER_EMAIL']
  s.summary     = <<~SUMMARY
  SUMMARY

  s.metadata = { 'type' => 'engine_type' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  Gemhelper.common(s)
end
