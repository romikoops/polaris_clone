# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "profiles"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "An engine for hosting user profiles"

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "users"

  spec.add_dependency "paranoia"
  spec.add_dependency "pg_search"

  spec.add_development_dependency "organizations"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
