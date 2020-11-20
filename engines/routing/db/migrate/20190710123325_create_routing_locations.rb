class CreateRoutingLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :routing_locations, id: :uuid do |t|
      t.string :locode, index: true, unique: true
      t.geometry :center, index: true
      t.geometry :bounds, limit: {srid: 0, type: "geometry"}
      t.string :name
      t.string :country_code
      t.timestamps
    end
  end
end
