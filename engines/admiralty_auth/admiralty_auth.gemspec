# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-admiralty_auth'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = 'Provides super-admin authentication for Admiralty.'

  s.metadata = { 'type' => 'view' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-admiralty_assets'
  s.add_dependency 'imc-core'

  s.add_dependency 'google_sign_in', '~> 1.1.2'

  Gemhelper.common(s)
end
