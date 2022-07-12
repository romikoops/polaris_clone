# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "ledger"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Engine responsible for advanced rate management"
  spec.required_ruby_version = ">= 2.7.5"

  spec.metadata["type"] = "data"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord_json_validator", "> 2.1"
  spec.add_dependency "organizations"
  spec.add_dependency "shared-runtime"
  spec.add_dependency "users"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
  spec.metadata["rubygems_mfa_required"] = "true"
end
