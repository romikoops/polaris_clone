class FixVehicleId < ActiveRecord::Migration[5.1]
  def change
    add_column :tenant_vehicles, :name, :string
  end
end
