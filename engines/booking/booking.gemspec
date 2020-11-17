# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "booking"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Data layer for all booking related services"

  spec.metadata["type"] = "data"

  spec.files = Dir["{app,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "companies"
  spec.add_dependency "organizations"
  spec.add_dependency "users"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "legacy"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
