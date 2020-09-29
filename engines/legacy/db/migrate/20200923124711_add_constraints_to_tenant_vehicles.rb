class AddConstraintsToTenantVehicles < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<-SQL
        ALTER TABLE tenant_vehicles
          ADD CONSTRAINT tenant_vehicles_upsert
          EXCLUDE (
            organization_id WITH =,
            name WITH =,
            mode_of_transport WITH =,
            carrier_id WITH =
          )
          WHERE (deleted_at IS NULL)
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
        ALTER TABLE tenant_vehicles
          DROP CONSTRAINT tenant_vehicles_upsert;
      SQL
    end
  end
end
