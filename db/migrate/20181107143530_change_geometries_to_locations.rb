class ChangeGeometriesToLocations < ActiveRecord::Migration[5.2]
  def change
    safety_assured {
      remove_column :trucking_destinations, :geometry_id, :integer
      add_column :trucking_destinations, :location_id, :integer
    }
  end
end
