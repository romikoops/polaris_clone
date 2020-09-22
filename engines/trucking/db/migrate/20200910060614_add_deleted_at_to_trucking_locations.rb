class AddDeletedAtToTruckingLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_locations, :deleted_at, :datetime, index: true
  end
end
