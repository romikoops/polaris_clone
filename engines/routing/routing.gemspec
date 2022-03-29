# frozen_string_literal: true

# Describe your gem and declare its dependencies:
# rubocop:disable Gemspec/RequireMFA
Gem::Specification.new do |spec|
  spec.name = "routing"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provides information about routing."
  spec.required_ruby_version = ">= 2.7.3"

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "activerecord-import"
  spec.add_dependency "bitfields"
  spec.add_dependency "rgeo", "~> 2.4.0"
  spec.add_dependency "rgeo-geojson"

  spec.add_development_dependency "legacy"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
# rubocop:enable Gemspec/RequireMFA
