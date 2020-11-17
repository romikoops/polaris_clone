# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "admiralty"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = <<~SUMMARY
    This engine provides super-admin view for managing tenants and accessing
    financial reports.
  SUMMARY

  spec.metadata["type"] = "direct"

  spec.files = Dir["{app,config,lib}/**/*"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "admiralty_assets"
  spec.add_dependency "admiralty_auth"
  spec.add_dependency "admiralty_reports"
  spec.add_dependency "admiralty_tenants"
  spec.add_dependency "legacy"
  spec.add_dependency "organization_manager"
  spec.add_dependency "organizations"
  spec.add_dependency "quotations"
  spec.add_dependency "shipments"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
