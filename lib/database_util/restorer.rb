# frozen_string_literal: true
require "aws-sdk-s3"

class DatabaseUtil
  class Restorer
    def initialize(profile:)
      @profile = profile
    end

    # Load database dump to template database
    def load(seed_file:)
      return if restored_date == seed_file.mtime

      create_template
      restore(seed_file)
    end

    # Creates develoment database from template
    def create
      execute(%(DROP DATABASE IF EXISTS "#{database_name}"))
      execute(%(CREATE DATABASE "#{database_name}" TEMPLATE ".polaris_#{profile}"))
    end

    def exists?
      execute(
        "SELECT 1 FROM pg_shdescription" \
        " JOIN pg_database ON objoid = pg_database.oid" \
        " WHERE datname = '.polaris_#{profile}'"
      ).count.nonzero?
    end

    def restored_date
      DateTime.parse(
        exists? && execute(
          "SELECT description FROM pg_shdescription" \
          " JOIN pg_database ON objoid = pg_database.oid" \
          " WHERE datname = '.polaris_#{profile}'"
        ).first["description"] || "20000101T000000"
      )
    end

    private

    attr_reader :profile

    def execute(sql, database = "template1")
      ActiveRecord::Base.establish_connection(database_url(database))
        .connection.execute(sql)
    end

    def database_url(database = nil)
      format(
        "postgres://%<username>s:%<password>s@%<host>s:%<port>s/%<database>s",
        username: ActiveRecord::Base.configurations[Rails.env]["username"],
        password: ActiveRecord::Base.configurations[Rails.env]["password"],
        host: ActiveRecord::Base.configurations[Rails.env]["host"],
        port: ActiveRecord::Base.configurations[Rails.env]["port"],
        database: database_name(database)
      )
    end

    def database_name(database = nil)
      database || ActiveRecord::Base.configurations[Rails.env]["database"]
    end

    def create_template
      execute(%(DROP DATABASE IF EXISTS ".polaris_#{profile}"))
      execute(%(CREATE DATABASE ".polaris_#{profile}"))
    end

    def restore(seed_file)
      puts "Restoring #{seed_file} to template database .polaris_#{profile}"
      puts ""
      puts "NOTE: Restore takes around 50 minutes."
      puts ""

      pg_restore_cmd = `which pg_restore`.strip

      fail("Please install PostgreSQL (pg_restore)") if pg_restore_cmd.blank?

      cmd = [
        pg_restore_cmd,
        "--dbname=#{database_url(".polaris_#{profile}")}",
        "--no-owner",
        "--no-privileges",
        seed_file.to_s
      ]

      system(*cmd) || exit(1)

      execute(%(COMMENT ON DATABASE ".polaris_#{profile}" IS '#{seed_file.mtime.iso8601}'))
    end
  end
end
