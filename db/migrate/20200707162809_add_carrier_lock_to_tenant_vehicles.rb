class AddCarrierLockToTenantVehicles < ActiveRecord::Migration[5.2]
  def up
    add_column :tenant_vehicles, :carrier_lock, :boolean
    change_column_default :tenant_vehicles, :carrier_lock, false
  end

  def down
    remove_column :tenant_vehicles, :carrier_lock
  end
end
