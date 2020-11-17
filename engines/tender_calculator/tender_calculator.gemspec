# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "tender_calculator"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = <<~SUMMARY
    Responsible for calculating line items for a tender out of the input fees.
  SUMMARY

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "cargo"
  spec.add_dependency "rate_extractor"
  spec.add_dependency "rates"
  spec.add_dependency "tenant_routing"

  spec.add_development_dependency "quotations"
  spec.add_development_dependency "legacy"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
