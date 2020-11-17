# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "rate_extractor"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = <<~SUMMARY
    This Engine is responsible for loading all rates and fees and associating them with the targets they apply to, within a quotation
  SUMMARY

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "cargo"
  spec.add_dependency "organization_manager"
  spec.add_dependency "quotations"
  spec.add_dependency "rates"
  spec.add_dependency "routing"
  spec.add_dependency "tenant_routing"

  spec.add_dependency "draper", "~> 4.0"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
