class AddingTenantVehicleToPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :pricings, :tenant_vehicle_id, :integer
  end
end
