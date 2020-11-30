# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "admiralty_reports"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provides financal reporting for Admiralty."

  spec.metadata["type"] = "api"

  spec.files = Dir["{app,config,lib}/**/*"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "admiralty_assets"
  spec.add_dependency "admiralty_auth"
  spec.add_dependency "companies"
  spec.add_dependency "quotations"
  spec.add_dependency "organizations"
  spec.add_dependency "organization_manager"

  spec.add_dependency "axlsx"
  spec.add_dependency "axlsx_rails"
  spec.add_dependency "rubyzip"

  spec.add_development_dependency "roo"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
