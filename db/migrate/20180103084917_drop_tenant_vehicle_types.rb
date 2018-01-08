class DropTenantVehicleTypes < ActiveRecord::Migration[5.1]
  def change
	  drop_table :tenant_vehicle_types
  end
end
