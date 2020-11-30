# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "address_book"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = <<~SUMMARY
    This engine is used to work with addresses and contacts for shipments.
    eg: consignee, consignor, notifyees.
  SUMMARY

  spec.metadata["type"] = "data"

  spec.files = Dir["{lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "organizations"

  spec.add_dependency "geocoder"
  spec.add_dependency "pg_search"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
