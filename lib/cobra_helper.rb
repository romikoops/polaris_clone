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
  }.freeze

  def self.uml(output: Pathname.new("../doc/engines").expand_path(__dir__))
    FileUtils.mkdir output unless File.directory?(output)
    output_file = output.join("graph.puml")
    output_file.open("w") do |io|
      io.puts new.uml
    end
  end

  def uml
    uml = []
    uml << "@startuml"

    packages.each do |package, specs|
      uml << "package \"#{package}\" {"

      specs.each do |spec|
        uml << "  class #{spec.name} << #{TYPE[spec.metadata['type']]} >>"
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
      .select { |spec| spec.source.respond_to?(:path) && spec.source.path.to_s[/engines/] }
      .map { |spec| [spec.name, spec] }.to_h
  end

  def packages
    @packages ||= specs.values.group_by do |spec|
      spec.metadata.fetch("package") { spec.metadata.fetch("type") }
    end
  end
end
