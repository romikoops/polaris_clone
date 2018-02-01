class CreateStops < ActiveRecord::Migration[5.1]
  def change
    create_table :stops do |t|
      t.integer :hub_id
      t.integer :itinerary_id
      t.integer :index
      t.timestamps
    end
  end
end
