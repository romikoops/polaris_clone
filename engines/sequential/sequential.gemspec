# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.expand_path('../../lib/engines/gemhelper.rb', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'imc-sequential'
  s.version     = '1'
  s.authors     = ['ItsMyCargo ApS']
  s.summary     = <<~SUMMARY
    The Sequential Engine generates gapless sequential numbers, primarily for
    invoice numbers. It handles race conditions, and it is generic, so that it
    can be used for creating counters of other purposes
  SUMMARY

  s.metadata = { 'type' => 'data' }

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  s.add_dependency 'imc-core'

  s.add_development_dependency 'database_cleaner'

  Gemhelper.common(s)
end
