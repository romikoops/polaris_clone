# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "wheelhouse"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = <<~SUMMARY
    This engine houses logic that proxies internal quotations to the offer
    calculator engine
  SUMMARY

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "cargo"
  spec.add_dependency "legacy"
  spec.add_dependency "offer_calculator"
  spec.add_dependency "pdf"
  spec.add_dependency "organizations"
  spec.add_dependency "organization_manager"

  spec.add_dependency "draper", "~> 4.0"
  spec.add_dependency "write_xlsx"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
