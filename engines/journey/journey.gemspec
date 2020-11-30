# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "journey"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = ""

  spec.metadata["type"] = "data"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"
  spec.add_dependency "measured-itsmycargo"

  spec.add_dependency "rein"
  spec.add_dependency "date_validator"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
