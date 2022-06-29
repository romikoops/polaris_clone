# frozen_string_literal: true

class CreateJourneyAddendums < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_addendums, id: :uuid do |t|
      t.references :shipment_request, type: :uuid, index: true,
        foreign_key: { to_table: "journey_shipment_requests" }

      t.string :label_name, null: false
      t.string :value, null: false
      t.timestamps
    end
    add_index :journey_addendums, %i[shipment_request_id label_name], unique: true
  end
end
