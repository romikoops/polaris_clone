# frozen_string_literal: true

class AddUniqueConstraintToLocationsLocations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_lock_timeout(1000)
  set_statement_timeout(15_000)

  def up
    safety_assured do
      execute <<-SQL
        CREATE UNIQUE INDEX CONCURRENTLY locations_locations_upsert ON locations_locations (name, country_code);
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
        DROP INDEX IF EXISTS locations_locations_upsert;
      SQL
    end
  end
end
