# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "excel_data_services"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = <<~SUMMARY
    Engine responsible for parsing, validating, mangling and inserting all data in the system
  SUMMARY

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,lib}/**/*"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "mimemagic"
  spec.add_dependency "roo"
  spec.add_dependency "roo-xls"
  spec.add_dependency "rover-df", "0.2.4"
  spec.add_dependency "write_xlsx"

  spec.add_dependency "companies"
  spec.add_dependency "groups"
  spec.add_dependency "legacy"
  spec.add_dependency "locations"
  spec.add_dependency "pricings"
  spec.add_dependency "routing"
  spec.add_dependency "organizations"
  spec.add_dependency "organization_manager"
  spec.add_dependency "trucking"
  spec.add_dependency "users"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
