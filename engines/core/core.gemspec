# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'core'
  s.version     = '0.0.1'
  s.authors     = ['Mikko Kokkonen']
  s.email       = ['mikko.kokkonen@itsmycargo.com']
  s.summary     = 'Core Requirements of IMC'

  s.add_dependency 'activerecord-postgis-adapter', '5.2.1'
  s.add_dependency 'pg', '0.21.0'
  s.add_dependency 'rails', '5.2.1'
end
