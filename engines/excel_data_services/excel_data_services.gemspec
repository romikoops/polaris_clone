# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require File.expand_path("../../lib/engines/gemhelper.rb", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "imc-excel_data_services"
  s.version = "1"
  s.authors = ["ItsMyCargo ApS"]
  s.summary = <<~SUMMARY
    Engine responsible for parsing, validating, mangling and inserting all data in the system
  SUMMARY

  s.metadata = {"type" => "service"}

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]

  s.add_dependency "mimemagic"
  s.add_dependency "roo"
  s.add_dependency "roo-xls"
  s.add_dependency "rover-df"
  s.add_dependency "sentry-raven"
  s.add_dependency "write_xlsx"

  s.add_dependency "imc-authentication"
  s.add_dependency "imc-companies"
  s.add_dependency "imc-groups"
  s.add_dependency "imc-legacy"
  s.add_dependency "imc-locations"
  s.add_dependency "imc-pricings"
  s.add_dependency "imc-organizations"
  s.add_dependency "imc-organization_manager"
  s.add_dependency "imc-trucking"
  s.add_dependency "imc-users"

  Gemhelper.common(s)
end
