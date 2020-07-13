# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require File.expand_path("../../lib/engines/gemhelper.rb", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "imc-authentication"
  s.version = "1"
  s.authors = ["ItsMyCargo ApS"]
  s.summary = <<~SUMMARY
  SUMMARY

  s.metadata = {"type" => "service"}

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]

  s.add_dependency "imc-organizations"
  s.add_dependency "imc-organization_manager"
  s.add_dependency "imc-users"
  s.add_dependency "imc-groups"

  s.add_dependency "mjml-rails"
  s.add_dependency "sorcery", "~> 0.15"

  Gemhelper.common(s)
end
