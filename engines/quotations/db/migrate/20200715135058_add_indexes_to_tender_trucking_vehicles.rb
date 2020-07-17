class AddIndexesToTenderTruckingVehicles < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :quotations_tenders, :pickup_tenant_vehicle_id, {algorithm: :concurrently}
    add_index :quotations_tenders, :delivery_tenant_vehicle_id, {algorithm: :concurrently}
  end
end
