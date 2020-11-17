# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "routing"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provides information about routing."

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "activerecord-import"
  spec.add_dependency "bitfields"
  spec.add_dependency "rgeo", "~> 2.1.1"
  spec.add_dependency "rgeo-geojson"

  spec.add_development_dependency "legacy"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
