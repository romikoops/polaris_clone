class RemoveShipperLocationIdFromShipments < ActiveRecord::Migration[5.1]
  def change
    remove_column :shipments, :shipper_location_id, :integer
  end
end
