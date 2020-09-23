class DropMigratorUniqueTenantVehiclesSyncs < ActiveRecord::Migration[5.2]
  def change
    drop_table :migrator_unique_tenant_vehicles_syncs
  end
end
