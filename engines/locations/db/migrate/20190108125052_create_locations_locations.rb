class CreateLocationsLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations_locations, id: :uuid do |t|
      t.geometry "bounds", limit: {:srid=>0, :type=>"geometry"}
      t.timestamps
    end
  end
end
