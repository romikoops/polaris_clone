# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "migrator"
  spec.version = "1"
  spec.license = "PROPRIETARY"
  spec.authors = ["Mikko Kokkonen"]
  spec.email = ["mikko.kokkonen@itsmycargo.com"]
  spec.summary = ""

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "locations"
  spec.add_dependency "organizations"
  spec.add_dependency "users"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
