# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "ledger"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Data layer for all Pricing and Margin related services."

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "cargo"
  spec.add_dependency "organizations"
  spec.add_dependency "routing"
  spec.add_dependency "tenant_routing"

  spec.add_dependency "money-rails"
  spec.add_dependency "uuidtools"

  spec.add_development_dependency "legacy"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
