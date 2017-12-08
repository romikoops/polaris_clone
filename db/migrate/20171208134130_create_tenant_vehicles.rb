class CreateTenantVehicles < ActiveRecord::Migration[5.1]
  def change
    create_table :tenant_vehicles do |t|
      t.integer :vehicle_id
      t.integer :tenant_id
      t.boolean :is_default
      t.string :mode_of_transport
      t.timestamps
    end
  end
end
