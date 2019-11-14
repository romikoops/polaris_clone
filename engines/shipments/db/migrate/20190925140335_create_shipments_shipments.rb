# frozen_string_literal: true

class CreateShipmentsShipments < ActiveRecord::Migration[5.2]
  def change
    create_table :shipments_shipments, id: :uuid do |t|
      t.references :shipment_request, type: :uuid, index: true
      t.references :sandbox, foreign_key: { to_table: :tenants_sandboxes }, type: :uuid, index: true
      t.references :user, foreign_key: { to_table: :tenants_users }, type: :uuid, index: true, null: false
      t.references :origin, foreign_key: { to_table: :routing_terminals }, type: :uuid, index: true, null: false
      t.references :destination, foreign_key: { to_table: :routing_terminals }, type: :uuid, index: true, null: false
      t.references :tenant, foreign_key: { to_table: :tenants_tenants }, type: :uuid, index: true, null: false

      t.string :status
      t.string :notes
      t.string :incoterm_text
      t.string :eori
      t.timestamps
    end
  end
end
