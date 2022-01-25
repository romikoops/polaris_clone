# frozen_string_literal: true
rails_version = File.read(File.join(__dir__, "../../.rails-version"))

Gem::Specification.new do |spec|
  spec.name = "shared-runtime"
  spec.version = "1"
  spec.authors = ["Mikko Kokkonen"]
  spec.email = ["mikko.kokkonen@itsmycargo.com"]

  spec.summary = "Common runtime for Polaris"

  spec.files = Dir["{lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord-postgis-adapter"
  spec.add_dependency "activerecord-safer_migrations", "~> 3.0"
  spec.add_dependency "activestorage-cascade", "~> 0.1.1"
  spec.add_dependency "audited", "~> 4.9"
  spec.add_dependency "bootsnap", ">= 1.1.0"
  spec.add_dependency "config", "~> 2.2"
  spec.add_dependency "data_migrate", "~> 6.5.0"
  spec.add_dependency "paper_trail", "~> 10.3"
  spec.add_dependency "pg", ">= 0.18", "< 2.0"
  spec.add_dependency "rails", rails_version
  spec.add_dependency "rails_event_store", "~> 1.2.2"
  spec.add_dependency "sidekiq", "~> 6.1"
  spec.add_dependency "sidekiq-status", "~> 1.1.4"
  spec.add_dependency "skylight"
  spec.add_dependency "strong_migrations", "~> 0.6"

  spec.add_development_dependency "rspec", "~> 3.9"
end
