# rubocop:disable Gemspec/RequiredRubyVersion
# frozen_string_literal: true

# rubocop:enable Gemspec/RequiredRubyVersion

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "schedules"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = ""

  spec.metadata["type"] = "data"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
