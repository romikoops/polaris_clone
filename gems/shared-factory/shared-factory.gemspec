rails_version = File.read(File.join(__dir__, "../../.rails-version"))

Gem::Specification.new do |spec|
  spec.name = "shared-factory"
  spec.version = "1"
  spec.authors = ["ItsMyCargo"]
  spec.summary = ""

  spec.add_dependency "rails", rails_version

  spec.add_dependency "factory_bot_rails", "~> 6.1"
  spec.add_dependency "ffaker", "~> 2.17"

  spec.add_development_dependency "rspec", "~> 3.9"
end
