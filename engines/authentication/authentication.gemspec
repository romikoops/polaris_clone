# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "authentication"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = <<~SUMMARY
  SUMMARY

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "organizations"
  spec.add_dependency "organization_manager"
  spec.add_dependency "users"
  spec.add_dependency "groups"

  spec.add_dependency "mjml-rails"
  spec.add_dependency "sorcery", "~> 0.15"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
