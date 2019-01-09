# frozen_string_literal: true

namespace :cobra do
  desc 'Outputs dependency graph'
  task :graph do
    require 'bundler'

    # lockfile = Bundler::LockfileParser.new(Bundler.read_file(Bundler.default_lockfile))
    definition = Bundler::Definition.build(Bundler.default_gemfile, Bundler.default_lockfile, false)

    # Find all engine specs
    specs = definition.specs
                      .select { |s| s.source.respond_to?(:path) && s.source.path.to_s[/engines/] }
                      .map { |s| [s.name, s] }
                      .to_h

    Tempfile.open('cobra.dot') do |io|
      io.puts 'digraph Engines {'
      io.puts 'app [shape=box];'

      specs.each do |_, s|
        io.puts "#{s.name} [shape=ellipse];"

        # Direct Requirements (Gem driven)
        io.puts "app -> #{s.name}" if s.metadata['type'] == 'direct'

        # Dependencies
        s.dependencies
         .select { |d| specs.has_key?(d.name) }
         .each do |d|
          io.puts "#{s.name} -> #{d.name} [color=grey];"
        end
      end
      io.puts '}'

      io.close
      sh "dot -Tpdf -odoc/cobra.pdf #{io.path}"
    end
  end
end
