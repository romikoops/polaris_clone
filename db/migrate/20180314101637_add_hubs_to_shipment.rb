class AddHubsToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :origin_hub_id, :integer
    add_column :shipments, :destination_hub_id, :integer
  end
end
