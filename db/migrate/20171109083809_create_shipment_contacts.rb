# frozen_string_literal: true

class CreateShipmentContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :shipment_contacts do |t|
      t.integer :shipment_id
      t.integer :contact_id
      t.string :contact_type
      t.timestamps
    end
  end
end
