# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "trucking"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Trucking related rates"

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "groups"
  spec.add_dependency "legacy"
  spec.add_dependency "locations"
  spec.add_dependency "organizations"

  spec.add_dependency "geocoder"
  spec.add_dependency "paranoia"
  spec.add_dependency "roo"
  spec.add_dependency "roo-xls"
  spec.add_dependency "uuidtools"
  spec.add_dependency "will_paginate"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
