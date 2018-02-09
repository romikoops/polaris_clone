class MoveVehicleIdToTrip < ActiveRecord::Migration[5.1]
  def change
    add_column :trips, :vehicle_id, :integer
    remove_column :itineraries, :vehicle_id, :integer
  end
end
