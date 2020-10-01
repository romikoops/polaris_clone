# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require File.expand_path("../../lib/engines/gemhelper.rb", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "imc-rms_sync"
  s.version = "1"
  s.authors = ["ItsMyCargo ApS"]
  s.summary = "RMS - Sync rates from legacy to RMS"

  s.metadata = {"type" => "service"}

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]

  s.add_dependency "activerecord-import"

  s.add_dependency "imc-core"
  s.add_dependency "imc-legacy"
  s.add_dependency "imc-groups"
  s.add_dependency "imc-pricings"
  s.add_dependency "imc-rms_data"
  s.add_dependency "imc-routing"
  s.add_dependency "imc-organizations"

  Gemhelper.common(s)
end
