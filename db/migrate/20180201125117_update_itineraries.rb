class UpdateItineraries < ActiveRecord::Migration[5.1]
  def change
    add_column :itineraries, :name, :string
    add_column :itineraries, :mode_of_transport, :string
    add_column :itineraries, :vehicle_id, :integer
    add_column :itineraries, :tenant_id, :integer
  end
end
