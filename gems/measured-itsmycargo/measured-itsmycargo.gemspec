# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "measured-itsmycargo"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Custom wrapping of Meausred Gem with our specified units"

  spec.files = Dir["{lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 5.2.6"
  spec.add_dependency "measured", "~> 2.8.2"
  spec.add_dependency "rake", "~> 13.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-cobertura"
  spec.add_development_dependency "webmock"
end
