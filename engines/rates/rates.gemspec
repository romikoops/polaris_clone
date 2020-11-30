# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "rates"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Data engine for rates and fees"

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "cargo"
  spec.add_dependency "organizations"
  spec.add_dependency "routing"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
