class FixVehicleId < ActiveRecord::Migration[5.1]
  def change
    add_column :schedules, :vehicle_id, :integer
    add_column :tenant_vehicles, :name, :string
    remove_column :schedules, :vehicle_type_id, :integer 
  end
end
