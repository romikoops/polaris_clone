# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "notifications"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provide central location for all notifications."

  spec.metadata["type"] = "data"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "organizations"
  spec.add_dependency "profiles"
  spec.add_dependency "users"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
