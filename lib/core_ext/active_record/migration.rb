# frozen_string_literal: true

module CoreExt
  module SchemaMigrationDetails
    def exec_migration(conn, direction)
      rval = nil

      time = Benchmark.measure do
        rval = super
      end

      # Only apply for newer migrations
      return rval if version < 20_180_913_232_620

      sql = <<SQL
      INSERT INTO schema_migration_details(
        version,
        hostname,
        name,
        git_version,
        duration,
        direction,
        rails_version,
        created_at
      ) values (
        :version,
        :hostname,
        :name,
        :git_version,
        :duration,
        :direction,
        :rails_version,
        :created_at
      )
SQL

      hostname = begin
        `hostname`
      rescue StandardError
        ''
      end
      sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, {
                                      version: version || '',
                                      duration: (time.real * 1000).to_i,
                                      hostname: hostname,
                                      name: name,
                                      git_version: nil,
                                      created_at: Time.zone.now,
                                      direction: direction.to_s,
                                      rails_version: Rails.version
                                    }])

      conn.execute(sql)

      rval
    end
  end
end

ActiveRecord::Migration.prepend CoreExt::SchemaMigrationDetails
