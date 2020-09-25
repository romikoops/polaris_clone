class AddTruckingLocationConstraints < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<-SQL
          ALTER TABLE trucking_locations
            ADD CONSTRAINT trucking_locations_upsert
            UNIQUE (data, query, country_id, deleted_at) ;
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
          ALTER TABLE trucking_locations
            DROP CONSTRAINT trucking_locations_upsert;
      SQL
    end
  end
end
