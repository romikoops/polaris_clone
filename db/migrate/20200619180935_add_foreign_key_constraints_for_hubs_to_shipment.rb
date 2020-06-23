class AddForeignKeyConstraintsForHubsToShipment < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :shipments, :hubs, column: :origin_hub_id, on_delete: :nullify, validate: false
    add_foreign_key :shipments, :hubs, column: :destination_hub_id, on_delete: :nullify, validate: false
  end
end
