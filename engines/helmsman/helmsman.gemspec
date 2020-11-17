# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "helmsman"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = "Validating possible routes for tenant."

  spec.metadata["type"] = "service"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "shared-runtime"

  spec.add_dependency "federation"
  spec.add_dependency "ledger"
  spec.add_dependency "organization_manager"
  spec.add_dependency "organizations"
  spec.add_dependency "routing"
  spec.add_dependency "tenant_routing"

  spec.add_development_dependency "companies"
  spec.add_development_dependency "legacy"

  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 4.0.1"
end
