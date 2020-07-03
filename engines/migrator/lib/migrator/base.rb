# frozen_string_literal: true

module Migrator
  class Base
    def self.depends_on(*parents)
      Dependency.add(self, parents)
    end

    def self.migrate
      new.perform
    end

    def perform
      updated = [*data].map { |sql| execute(sql, "#{self.class}#data") }.sum if data
      [*sync].each { |sql| execute(sql, "#{self.class}#sync") } if sync

      new_count, old_count = verify

      unless new_count == old_count
        puts "!! Verification has failed for #{self.class}"
        puts "Results: #{new_count} != #{old_count}"
        exit(1)
      end

      updated
    end

    def data
    end

    def sync
    end

    def verify
      [Array(count_migrated), Array(count_required)]
    end

    def count_migrated
    end

    def count_required
    end

    def migrator
      @migrator ||= Migrator.new
    end

    delegate :say, :say_with_time, :exec_update, :columns, to: :migrator

    def execute(sql, name)
      exec_update(sql.tr("\n", " "), name)
    end

    def count(sql)
      ActiveRecord::Base.connection.execute(sql.tr("\n", " ")).first["count"]
    end

    def tables
      migrator.tables.reject { |table|
        table.starts_with?("migrator") || table[/_\d+\z/]
      }
    end

    class Migrator < ActiveRecord::Migration::Current
      disable_ddl_transaction!

      def execute(*args)
        safety_assured { super }
      end
    end
  end
end
