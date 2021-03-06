# frozen_string_literal: true

# rubocop:disable Gemspec/RequireMFA
Gem::Specification.new do |spec|
  spec.name = "api_auth"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Provides authentication for API endpoints."

  spec.metadata["type"] = "api"

  spec.files = Dir["{app,config,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "organizations"
  spec.add_dependency "users"

  spec.add_dependency "active_model_serializers", "~> 0.10", ">= 0.10.8"
  spec.add_dependency "doorkeeper", "~> 5.5.4"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
# rubocop:enable Gemspec/RequireMFA
