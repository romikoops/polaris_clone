# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "federation"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Services for prociding contextual information regarding pricing Federations."

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "organizations"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
