# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-legacy'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Dumpster for old legacy code that is needed in other engines.'

  s.metadata = { 'type' => 'data' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-profiles'
  s.add_dependency 'imc-organizations'

  s.add_dependency 'active_model_serializers'
  s.add_dependency 'activerecord-import'
  s.add_dependency 'devise_token_auth', '~> 0.1.43'
  s.add_dependency 'draper'
  s.add_dependency 'fixer_currency', '~> 3.4'
  s.add_dependency 'geocoder'
  s.add_dependency 'mobility'
  s.add_dependency 'money-rails'
  s.add_dependency 'paranoia'
  s.add_dependency 'pg_search', '~> 2.3.0'

  s.add_development_dependency 'imc-quotations'

  Gemhelper.common(s)
end
