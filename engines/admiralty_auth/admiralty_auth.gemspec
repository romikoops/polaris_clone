# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "admiralty_auth"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provides super-admin authentication for Admiralty."

  spec.metadata["type"] = "api"

  spec.files = Dir["{app,config,lib}/**/*"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "admiralty_assets"

  spec.add_dependency "google_sign_in", "~> 1.1.2"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
