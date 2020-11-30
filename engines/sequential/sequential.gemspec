# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "sequential"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = <<~SUMMARY
    The Sequential Engine generates gapless sequential numbers, primarily for
    invoice numbers. It handles race conditions, and it is generic, so that it
    can be used for creating counters of other purposes
  SUMMARY

  spec.metadata["type"] = "data"

  spec.files = Dir["{app,db,lib}/**/*"]

  spec.add_dependency "shared-runtime"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
