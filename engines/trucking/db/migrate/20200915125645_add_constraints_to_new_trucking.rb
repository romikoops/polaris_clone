class AddConstraintsToNewTrucking < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<-SQL
        CREATE TABLE new_trucking_truckings AS 
        TABLE trucking_truckings 
        WITH NO DATA;
      SQL
      execute <<-SQL
          ALTER TABLE new_trucking_truckings
            ADD CONSTRAINT trucking_upsert
            EXCLUDE USING gist (
              hub_id WITH =,
              carriage WITH =,
              load_type WITH =,
              cargo_class WITH =,
              location_id WITH =,
              organization_id WITH =,
              truck_type WITH =,
              group_id WITH =,
              tenant_vehicle_id WITH =,
              validity WITH &&
            )
            WHERE (deleted_at IS NULL);
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
        DROP TABLE IF EXISTS new_trucking_truckings;
      SQL
    end
  end
end
