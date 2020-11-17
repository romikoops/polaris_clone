# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "validator"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.email = ["mikko.kokkonen@itsmycargo.com"]
  spec.summary = <<~SUMMARY
    Validator takes an itinerary and checks each part of the journey for
    matching TenantVehicles, valid Pricings and available Schedules
  SUMMARY

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "groups"
  spec.add_dependency "legacy"
  spec.add_dependency "pricings"
  spec.add_dependency "organizations"
  spec.add_dependency "organization_manager"
  spec.add_dependency "trucking"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
