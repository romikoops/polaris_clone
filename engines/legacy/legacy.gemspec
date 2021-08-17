# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "legacy"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Dumpster for old legacy code that is needed in other engines."

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "groups"
  spec.add_dependency "organizations"

  spec.add_dependency "active_model_serializers"
  spec.add_dependency "activerecord-import"
  spec.add_dependency "activejob-traffic_control"
  spec.add_dependency "draper"
  spec.add_dependency "fixer_currency", "~> 3.4"
  spec.add_dependency "geocoder"
  spec.add_dependency "mobility"
  spec.add_dependency "money-rails"
  spec.add_dependency "paranoia"
  spec.add_dependency "pg_search", "~> 2.3.0"
  spec.add_dependency "uuidtools"

  spec.add_development_dependency "cargo"
  spec.add_development_dependency "companies"
  spec.add_development_dependency "organization_manager"
  spec.add_development_dependency "quotations"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
