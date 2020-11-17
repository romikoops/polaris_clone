# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "admiralty_tenants"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provides management of tenants in Admiralty."

  spec.metadata["type"] = "api"

  spec.files = Dir["{app,config,lib}/**/*"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "admiralty_assets"
  spec.add_dependency "admiralty_auth"
  spec.add_dependency "authentication"
  spec.add_dependency "legacy"
  spec.add_dependency "organization_manager"
  spec.add_dependency "organizations"
  spec.add_dependency "pricings"
  spec.add_dependency "profiles"
  spec.add_dependency "users"

  spec.add_dependency "draper"
  spec.add_dependency "jsoneditor-rails"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
