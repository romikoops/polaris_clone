# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require File.expand_path("../../lib/engines/gemhelper.rb", __dir__)

Gem::Specification.new do |spec|
  spec.name = "money_cache"
  spec.version = "0.1.0"
  spec.authors = ["ItsMyCargo APS"]

  spec.summary = "Custom exchange rate bank for money gem"
  spec.files = Dir["{lib}/**/*", "Rakefile"]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "money"
  spec.add_dependency "money-open-exchange-rates"
  spec.add_dependency "rake", "~> 13.0"

  spec.add_development_dependency "bundler", "~> 1.17.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-cobertura"
end
