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

  spec.metadata["package"] = "admiralty"
  spec.metadata["type"] = "direct"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{app,config,lib}/**/*"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "google_sign_in", "~> 1.2.0"
  spec.add_dependency "trestle", "~> 0.9.4"
  spec.add_dependency "trestle-active_storage", "~> 3.0.1"
  spec.add_dependency "trestle-auth", "~> 0.4.1"
  spec.add_dependency "trestle-jsoneditor"
  spec.add_dependency "trestle-rails_event_store"
  spec.add_dependency "trestle-search", "~> 0.4.3"
  spec.add_dependency "trestle-sidekiq", "~> 0.1.1"

  spec.add_dependency "distributions"
  spec.add_dependency "legacy"
  spec.add_dependency "organization_manager"
  spec.add_dependency "organizations"
  spec.add_dependency "quotations"
  spec.add_dependency "routing"
  spec.add_dependency "shipments"
  spec.add_dependency "tracker"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
