class AddOriginNexusIdToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :origin_nexus_id, :integer
  end
end
