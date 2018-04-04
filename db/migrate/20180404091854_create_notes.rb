class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.integer :itinerary_id
      t.integer :hub_id
      t.integer :trucking_pricing_id
      t.string :body
      t.string :header
      t.string :level
      t.timestamps
    end
    remove_column :itineraries, :notes, :string
  end
end
