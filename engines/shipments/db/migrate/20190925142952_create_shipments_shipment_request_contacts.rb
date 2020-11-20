# frozen_string_literal: true

class CreateShipmentsShipmentRequestContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :shipments_shipment_request_contacts, id: :uuid do |t|
      t.references :shipment_request, type: :uuid,
                                      index: {name: "index_shipment_request_contacts_on_shipment_request_id"},
                                      null: false
      t.references :contact, foreign_key: {to_table: :address_book_contacts},
                             type: :uuid,
                             index: {name: "index_shipment_request_contacts_on_contact_id"},
                             null: false
      t.string :type
      t.timestamps
    end
  end
end
