class AddGeometryIdToTruckingDestinations < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_destinations, :geometry_id, :integer
  end
end
