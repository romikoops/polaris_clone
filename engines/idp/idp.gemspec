# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "idp"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "IdP Provider"

  spec.metadata["type"] = "direct"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "doorkeeper"
  spec.add_dependency "ruby-saml", "~> 1.11.0"

  spec.add_dependency "authentication"
  spec.add_dependency "organization_manager"
  spec.add_dependency "organizations"
  spec.add_dependency "profiles"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
