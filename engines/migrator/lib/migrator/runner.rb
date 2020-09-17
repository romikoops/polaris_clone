# frozen_string_literal: true

module Migrator
  def self.run
    puts "Running data migrations:"
    puts Dependency.list.map { |dep| "  #{dep}" }.join("\n")

    updated = 0

    Dependency.list.each do |migrator|
      puts "-- #{migrator}"
      updated += migrator.migrate
    end

    puts "-- Total updated rows: #{updated}"
  end
end
