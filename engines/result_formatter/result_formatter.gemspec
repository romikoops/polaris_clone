# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require File.expand_path("../../lib/engines/gemhelper.rb", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "imc-result_formatter"
  s.version = "1"
  s.authors = ["ItsMyCargo ApS"]
  s.summary = <<~SUMMARY
    Formatting of Quotations::Tenders and LineItems
  SUMMARY

  s.metadata = {"type" => "service"}

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]

  s.add_dependency 'imc-legacy'
  s.add_dependency 'imc-pricings'
  s.add_dependency 'imc-quotations'

  Gemhelper.common(s)
end
