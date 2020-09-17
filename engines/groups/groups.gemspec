# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require File.expand_path("../../lib/engines/gemhelper.rb", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "imc-groups"
  s.version = "1"
  s.authors = ["ItsMyCargo ApS"]
  s.summary = <<~SUMMARY
  SUMMARY

  s.metadata = { "type" => "data" }

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]

  s.add_development_dependency "imc-organizations"
  s.add_development_dependency "imc-companies"

  s.add_dependency "paranoia"
  s.add_dependency "pg_search", "~> 2.3.0"

  Gemhelper.common(s)
end
