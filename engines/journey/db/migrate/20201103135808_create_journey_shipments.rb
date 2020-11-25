class CreateJourneyShipments < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_shipments, id: :uuid do |t|
      t.references :shipment_request, type: :uuid, index: true,
                                      foreign_key: {on_delete: :cascade, to_table: "journey_shipment_requests"}
      t.references :creator, type: :uuid, index: true,
                             foreign_key: {on_delete: :cascade, to_table: "users_users"}
      t.timestamps
    end
  end
end
