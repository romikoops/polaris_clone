# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "distributions"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Data Engine to persist the types of data manipulation actions required in the Rate Distribution process and logging info about when they were run."

  spec.metadata["type"] = "data"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
  spec.metadata["rubygems_mfa_required"] = "true"
end
