# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-api'
  s.version     = '1'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Mikko Kokkonen']
  s.email       = ['mikko.kokkonen@itsmycargo.com']
  s.summary     = 'Improved API for new frontend code.'

  s.metadata = { 'type' => 'view', 'direct' => 'true' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-api_auth'
  s.add_dependency 'imc-api_docs'
  s.add_dependency 'imc-core'
  s.add_dependency 'imc-profiles'
  s.add_dependency 'imc-tenants'
  s.add_dependency 'imc-trucking'
  s.add_dependency 'imc-wheelhouse'

  s.add_dependency 'active_model_serializers', '~> 0.10', '>= 0.10.8'

  Gemhelper.common(s)

  s.add_development_dependency 'rspec_api_documentation'
end
