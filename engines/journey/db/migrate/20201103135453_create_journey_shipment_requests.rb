class CreateJourneyShipmentRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_shipment_requests, id: :uuid do |t|
      t.references :result, type: :uuid, index: true,
                            foreign_key: {on_delete: :cascade, to_table: "journey_results"}
      t.references :client, type: :uuid, index: true,
                            foreign_key: {on_delete: :cascade, to_table: "users_users"}
      t.references :company, type: :uuid, index: true,
                             foreign_key: {on_delete: :cascade, to_table: "users_users"}
      t.string :preferred_voyage, null: false
      t.timestamps
    end

    safety_assured do
      add_presence_constraint :journey_shipment_requests, :preferred_voyage
    end
  end
end
