# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "admiralty_assets"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provides common assets for admiralty views."

  spec.metadata["type"] = "api"

  spec.files = Dir["{app,lib}/**/*"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "bootstrap", "~> 4.4.1"
  spec.add_dependency "jquery-rails"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
