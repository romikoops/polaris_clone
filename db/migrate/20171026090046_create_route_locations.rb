class CreateRouteLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :route_locations do |t|
    	t.integer :route_id
      t.integer :location_id
      t.integer :position_in_hub_chain
      t.timestamps
    end
  end
end
