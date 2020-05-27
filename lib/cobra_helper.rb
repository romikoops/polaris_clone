# frozen_string_literal: true

require "bundler"
require "digest"

class CobraHelper
  def self.graphviz(output: Pathname.new("../doc/engines").expand_path(__dir__))
    output_file = output.join("graph.dot")
    previous_sha = Digest::SHA256.file(output_file) if output_file.exist?
    output_file.open("w") do |io|
      io.puts new.graphviz
    end

    (previous_sha == Digest::SHA256.file(output_file)) ||
      system("dot -Tpdf -o#{output.join("graph.pdf")} #{output_file}")
  end

  def graphviz # rubocop:disable Metrics/AbcSize
    dot = []

    dot << "digraph G {"
    dot << "  compound=true;"

    dot << "  subgraph cluster0 {"
    dot << "    app [shape=box];"
    dot << "  }"

    groups.each_with_index do |(type, group), index|
      dot << "  subgraph cluster#{index + 1} {"
      dot << "    label = \"#{type}\";"

      group.each do |_, s|
        name = s.name.gsub(/\Aimc-/, "")

        dot << "    \"#{name}\" [shape=ellipse];"

        # Direct Requirements (Gem driven)
        dot << "    app -> \"#{name}\"" if s.metadata["direct"] == "true"

        # Dependencies
        s.dependencies.select { |d| specs.key?(d.name) }.each do |d|
          dot << "    \"#{name}\" -> \"#{d.name.gsub(/\Aimc-/, "")}\" [color=grey];"
        end
      end

      dot << "  };"
    end

    dot << "}"

    dot.join("\n")
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

  def groups
    @groups ||= specs.group_by { |_, s| s.metadata["type"] }
  end
end
