# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "locations"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provides location information."

  spec.metadata["type"] = "service"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "elasticsearch", "~> 7.10.0"
  spec.add_dependency "rgeo"
  spec.add_dependency "rgeo-geojson"
  spec.add_dependency "searchkick", "~> 5.0.3"

  spec.add_dependency "legacy"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
