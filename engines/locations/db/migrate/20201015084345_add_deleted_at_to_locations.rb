class AddDeletedAtToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations_locations, :deleted_at, :datetime
  end
end
