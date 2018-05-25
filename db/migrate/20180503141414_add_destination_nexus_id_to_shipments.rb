class AddDestinationNexusIdToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :destination_nexus_id, :integer
  end
end
