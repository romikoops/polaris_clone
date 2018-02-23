class AddTruckingToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :trucking, :jsonb
  end
end
