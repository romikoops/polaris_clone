# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "api"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Improved API for new frontend code."

  spec.metadata["package"] = "api"
  spec.metadata["type"] = "direct"

  spec.files = Dir["{lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "active_model_serializers", "~> 0.10.10"
  spec.add_dependency "draper", "~> 4.0"
  spec.add_dependency "fast_jsonapi"
  spec.add_dependency "google-iam-credentials", "~> 1.0.0"
  spec.add_dependency "kaminari"
  spec.add_dependency "money_cache"
  spec.add_dependency "sentry-rails"

  spec.add_dependency "analytics"
  spec.add_dependency "api_auth"
  spec.add_dependency "cargo"
  spec.add_dependency "carta"
  spec.add_dependency "cms_data"
  spec.add_dependency "dry-validation", "~> 1.6"
  spec.add_dependency "files"
  spec.add_dependency "journey"
  spec.add_dependency "organization_manager"
  spec.add_dependency "organizations"
  spec.add_dependency "pricings"
  spec.add_dependency "profiles"
  spec.add_dependency "result_formatter"
  spec.add_dependency "routing"
  spec.add_dependency "tracker"
  spec.add_dependency "treasury"
  spec.add_dependency "trucking"
  spec.add_dependency "users"
  spec.add_dependency "user_services"
  spec.add_dependency "wheelhouse"

  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
  spec.add_development_dependency "rswag-specs"
  spec.metadata["rubygems_mfa_required"] = "true"
end
