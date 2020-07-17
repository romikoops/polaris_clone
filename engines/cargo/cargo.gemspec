# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require File.expand_path("../../lib/engines/gemhelper.rb", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "imc-cargo"
  s.version = "1"
  s.authors = ["ItsMyCargo ApS"]
  s.summary = "Provides information of Cargo."

  s.metadata = {"type" => "service"}

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]

  # External Gems
  s.add_dependency "measured-rails"
  s.add_dependency "money-rails"

  # Internal Engines
  s.add_dependency "imc-core"
  s.add_dependency "imc-organizations"
  s.add_dependency "imc-legacy"

  Gemhelper.common(s)
end
