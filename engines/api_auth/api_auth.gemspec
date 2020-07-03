# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-api_auth'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Provides authentication for API endpoints.'

  s.metadata = { 'type' => 'view' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-users'
  s.add_dependency 'imc-organizations'
  s.add_dependency 'imc-authentication'


  s.add_dependency 'active_model_serializers', '~> 0.10', '>= 0.10.8'
  s.add_dependency 'doorkeeper', '~> 5.0.2'
  # s.add_dependency 'sorcery', '~> 0.13.0'

  Gemhelper.common(s)
end
