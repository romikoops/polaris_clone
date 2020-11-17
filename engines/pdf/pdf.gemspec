# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "pdf"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = ""

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"
  spec.add_dependency "money_cache"

  spec.add_dependency "draper", "~> 4.0"
  spec.add_dependency "pdfkit"
  spec.add_dependency "wkhtmltopdf-binary"

  spec.add_dependency "legacy"
  spec.add_dependency "notes"
  spec.add_dependency "organization_manager"
  spec.add_dependency "organizations"
  spec.add_dependency "pricings"
  spec.add_dependency "profiles"
  spec.add_dependency "quotations"
  spec.add_dependency "result_formatter"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
