# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'legacy'
  s.version     = '9999.1.0.0'
  s.license     = 'PROPRIETARY'
  s.authors     = ['Mikko Kokkonen']
  s.email       = ['mikko.kokkonen@itsmycargo.com']
  s.summary     = 'Summary of Legacy.'

  # Uncomment line below to mark this component to be directly required by app.
  # s.metadata = { 'type' => 'direct' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'core'
  s.add_dependency 'profiles'

  s.add_dependency 'active_model_serializers'
  s.add_dependency 'activerecord-import'
  s.add_dependency 'fixer_currency', '~> 3.4'
  s.add_dependency 'geocoder'
  s.add_dependency 'mobility'
  s.add_dependency 'paranoia'
  s.add_dependency 'pg_search', '~> 2.3.0'

  Gemhelper.common_gems(s)
end
