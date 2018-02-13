class CreateItineraries < ActiveRecord::Migration[5.1]
  def change
    create_table :itineraries do |t|
      t.string :name
      t.string :mode_of_transport
      t.integer :vehicle_id
      t.integer :tenant_id
      t.timestamps
    end
  end
end
