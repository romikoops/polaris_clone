# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "cargo"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provides information of Cargo."

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,data,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"
  spec.add_dependency "measured-itsmycargo"

  # External Gems
  spec.add_dependency "measured-rails", "~> 2.8.2"
  spec.add_dependency "money-rails"

  # Internal Engines
  spec.add_dependency "organizations"
  spec.add_dependency "organization_manager"
  spec.add_dependency "legacy"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
  spec.add_development_dependency "quotations"
end
