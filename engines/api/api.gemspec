# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-api'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Improved API for new frontend code.'

  s.metadata = { 'type' => 'view', 'direct' => 'true' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-analytics'
  s.add_dependency 'imc-api_auth'
  s.add_dependency 'imc-authentication'
  s.add_dependency 'imc-cargo'
  s.add_dependency 'imc-core'
  s.add_dependency 'imc-organizations'
  s.add_dependency 'imc-organization_manager'
  s.add_dependency 'imc-pricings'
  s.add_dependency 'imc-profiles'
  s.add_dependency 'imc-result_formatter'
  s.add_dependency 'imc-cms_data'
  s.add_dependency 'imc-trucking'
  s.add_dependency 'imc-users'
  s.add_dependency 'imc-wheelhouse'

  s.add_dependency 'draper', '~> 4.0'
  s.add_dependency 'fast_jsonapi'
  s.add_dependency 'kaminari'

  Gemhelper.common(s)

  s.add_development_dependency 'rswag-specs'
end
