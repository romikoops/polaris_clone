class AddTenantVehicleToTrips < ActiveRecord::Migration[5.1]
  def change
    remove_column :trips, :vehicle_id, :integer
    add_column :trips, :tenant_vehicle_id, :integer
  end
end
