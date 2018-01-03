class DropVehicleTypes < ActiveRecord::Migration[5.1]
  def change
  	drop_table :vehicle_types
  end
end
