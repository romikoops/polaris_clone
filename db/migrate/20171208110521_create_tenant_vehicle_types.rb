class CreateTenantVehicleTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :tenant_vehicle_types do |t|
      t.integer :vehicle_type_id
      t.integer :tenant_id
      t.boolean :is_default
      t.string :mode_of_transport
      t.timestamps
    end
  end
end
