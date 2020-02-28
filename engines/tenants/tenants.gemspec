# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-tenants'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Tenants related services'

  s.metadata = { 'type' => 'services' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-legacy'
  s.add_dependency 'imc-mailers'
  s.add_dependency 'imc-profiles'

  s.add_dependency 'activerecord-import'
  s.add_dependency 'paranoia'
  s.add_dependency 'pg_search', '~> 2.3.0'
  s.add_dependency 'sorcery', '~> 0.13.0'

  Gemhelper.common(s)
end
