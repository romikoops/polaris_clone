# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "shipments"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = <<~SUMMARY
    The Shipments Engine is responsible for handling the data level of shipment requests and shipments
  SUMMARY

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  # External gems
  spec.add_dependency "aasm"
  spec.add_dependency "money-rails", "~> 1.12"

  # pec Internal engines
  spec.add_dependency "address_book"
  spec.add_dependency "cargo"
  spec.add_dependency "quotations"
  spec.add_dependency "routing"
  spec.add_dependency "sequential"
  spec.add_dependency "organizations"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
