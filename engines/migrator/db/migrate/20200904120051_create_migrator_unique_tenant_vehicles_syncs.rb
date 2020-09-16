class CreateMigratorUniqueTenantVehiclesSyncs < ActiveRecord::Migration[5.2]
  def change
    create_table :migrator_unique_tenant_vehicles_syncs, id: :uuid do |t|
      t.references :unique_tenant_vehicle, references: :tenant_vehicles,
                                           foreign_key: {to_table: :tenant_vehicles},
                                           index: {name: "index_tenant_vehicles_syncs_on_unique_tenant_vehicle_id"}
      t.references :duplicate_tenant_vehicle, references: :tenant_vehicles,
                                              foreign_key: {to_table: :tenant_vehicles},
                                              index: {
                                                name: "index_tenant_vehicles_syncs_on_duplicate_tenant_vehicle_id"
                                              }

      t.index %i[unique_tenant_vehicle_id duplicate_tenant_vehicle_id],
        unique: true,
        name: :index_tenant_vehicles_syncs_on_unique_id_and_duplicate_id

      t.timestamps
    end
  end
end
