# frozen_string_literal: true

require "bundler"
require "digest"
require "fileutils"

class CobraHelper
  TYPE = {
    "api" => "(A,red)",
    "service" => "(S,yellow)",
    "data" => "(D,orange)",
    "direct" => "(*,blue)"
  }

  def self.uml(output: Pathname.new("../doc/engines").expand_path(__dir__))
    FileUtils.mkdir output unless File.directory?(output)
    output_file = output.join("graph.puml")
    previous_sha = Digest::SHA256.file(output_file) if output_file.exist?
    output_file.open("w") do |io|
      io.puts new.uml
    end

    if (plantuml = `which plantuml`.strip)
      (previous_sha == Digest::SHA256.file(output_file) && output.join("graph.svg").exist?) ||
        system("#{plantuml} -nometadata -duration -tsvg -o#{output} #{output_file}")
    else
      puts "Please install PlantUML (brew install plantuml) to generate graph"
    end
  end

  def uml
    uml = []
    uml << "@startuml"

    packages.each do |package, specs|
      uml << "package \"#{package}\" {"

      specs.each do |spec|
        uml << "  class #{spec.name} << #{TYPE[spec.metadata["type"]]} >>"
      end

      uml << "}"
    end

    # Dependencies
    specs.each do |name, spec|
      spec.dependencies.select { |d| specs.key?(d.name) }.each do |d|
        arrow = spec.metadata["type"] == specs[d.name].metadata["type"] ? "*-->" : "-->"
        uml << "#{name} #{arrow} #{d.name}"
      end
    end

    uml << "@enduml"
    uml.join("\n")
  end

  private

  def definition
    @definition ||= Bundler::Definition.build(Bundler.default_gemfile, Bundler.default_lockfile, false)
  end

  def specs
    @specs ||= definition.specs
      .select { |s| s.source.respond_to?(:path) && s.source.path.to_s[/engines/] }
      .map { |s| [s.name, s] }
      .to_h
  end

  def packages
    @packages ||= specs.values.group_by { |s| s.metadata.fetch("package") { s.metadata.fetch("type") } }
  end
end
