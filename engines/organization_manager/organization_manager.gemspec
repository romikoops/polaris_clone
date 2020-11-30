# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "organization_manager"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = ""

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "companies"
  spec.add_dependency "groups"
  spec.add_dependency "legacy"
  spec.add_dependency "organizations"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
