# frozen_string_literal: true

module Migrator
  class Dependency
    cattr_reader :dependencies
    @@dependencies = {}

    def self.add(klass, *parents)
      @@dependencies[klass] = parents.flatten
    end

    def self.tree
      @@tree ||= @@dependencies.map { |klass, deps|
        [klass, deps.collect { |dep| Migrator::Migrations.const_get(dep.camelcase) }]
      }.to_h
    end

    def self.list
      @@list ||= begin
        result = {}

        add_migrator = proc do |migrator, depth|
          result[migrator] = depth if !result.key?(migrator) || result[migrator] < depth
          next unless tree[migrator]

          tree[migrator].each do |dependency|
            add_migrator.call(dependency, depth + 1)
          end
        end

        # Get list of wanted migrators
        migrators = if ENV["MIGRATORS"]
          ENV["MIGRATORS"].collect { |migrator| Migrator::Migrations.const_get(migrator.camelcase) }
        else
          Base.descendants
        end

        migrators.each do |migrator|
          add_migrator.call(migrator, 0)
        end

        grouped = result.keys.group_by { |key| result[key] }
        grouped.keys.sort.reverse.flat_map { |idx| grouped[idx] }
      end
    end
  end
end
