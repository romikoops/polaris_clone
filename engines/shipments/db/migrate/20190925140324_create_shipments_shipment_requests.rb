# frozen_string_literal: true

class CreateShipmentsShipmentRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :shipments_shipment_requests, id: :uuid do |t|
      t.string :status
      t.string :cargo_notes
      t.string :notes
      t.string :incoterm_text
      t.string :eori
      t.string :ref_number, null: false
      t.datetime :submitted_at
      t.datetime :eta
      t.datetime :etd
      t.references :sandbox, foreign_key: { to_table: :tenants_sandboxes },
                             type: :uuid, index: true
      t.references :user, foreign_key: { to_table: :tenants_users },
                          type: :uuid, index: true, null: false
      t.references :tenant, foreign_key: { to_table: :tenants_tenants },
                            type: :uuid, index: true, null: false
      t.references :tender, foreign_key: { to_table: :quotations_tenders },
                            type: :uuid, index: true, null: false

      t.timestamps
    end
  end
end
