# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require File.expand_path("../../lib/engines/gemhelper.rb", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "imc-organizations"
  s.version = "1"
  s.license = "PROPRIETARY"
  s.authors = ["Mikko Kokkonen"]
  s.email = ["mikko.kokkonen@itsmycargo.com"]
  s.summary = <<~SUMMARY
  SUMMARY

  s.metadata = { "type" => "data" }

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]

  s.add_dependency "imc-users"

  Gemhelper.common(s)
end
