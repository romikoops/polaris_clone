# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "integrations"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provides integration with 3rd party systems."

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "companies"
  spec.add_dependency "legacy"
  spec.add_dependency "organization_manager"
  spec.add_dependency "profiles"
  spec.add_dependency "shipments"

  spec.add_development_dependency "json-schema"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
