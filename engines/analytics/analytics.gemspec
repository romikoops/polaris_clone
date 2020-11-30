# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "analytics"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = <<~SUMMARY
    Analytics service engine for pulling in and manipulating data for use
    in the Bridge analytics page
  SUMMARY
  spec.metadata["type"] = "service"

  spec.files = Dir["{lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "companies"
  spec.add_dependency "legacy"
  spec.add_dependency "organizations"
  spec.add_dependency "organization_manager"
  spec.add_dependency "pricings"
  spec.add_dependency "quotations"
  spec.add_dependency "shipments"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
