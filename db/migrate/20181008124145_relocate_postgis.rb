# frozen_string_literal: true

class RelocatePostgis < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      results = ActiveRecord::Base.connection.execute(
        <<-SQL
          SELECT extversion
            FROM pg_catalog.pg_extension
            WHERE extname='postgis'
        SQL
      )
      version = results.first['extversion']

      execute <<-SQL
        CREATE SCHEMA IF NOT EXISTS extensions;

        UPDATE pg_extension
          SET extrelocatable = TRUE
            WHERE extname = 'postgis';

        ALTER EXTENSION postgis
          SET SCHEMA extensions;

        ALTER EXTENSION postgis
          UPDATE TO '#{version}next';

        ALTER EXTENSION postgis
          UPDATE TO '#{version}'
      SQL
    end
  end
end
