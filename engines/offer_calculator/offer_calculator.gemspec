# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "offer_calculator"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "This engine houses the logic for determining offers in the legacy system"

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"
  spec.add_dependency "money_cache"

  spec.add_dependency "legacy"
  spec.add_dependency "notes"
  spec.add_dependency "organizations"
  spec.add_dependency "organization_manager"
  spec.add_dependency "pricings"
  spec.add_dependency "quotations"
  spec.add_dependency "result_formatter"
  spec.add_dependency "trucking"

  spec.add_dependency "chronic"
  spec.add_dependency "measured"
  spec.add_dependency "sentry-raven"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
