# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-offer_calculator'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'This engine houses the logic for determining offers in the legacy system'

  s.metadata = { 'type' => 'services' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'
  s.add_dependency 'imc-legacy'
  s.add_dependency 'imc-pricings'
  s.add_dependency 'imc-quotations'
  s.add_dependency 'imc-tenants'
  s.add_dependency 'imc-trucking'

  s.add_dependency 'chronic'
  s.add_dependency 'sentry-raven'

  Gemhelper.common(s)
end
