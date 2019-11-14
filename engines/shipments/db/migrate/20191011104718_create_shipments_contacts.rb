# frozen_string_literal: true

class CreateShipmentsContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :shipments_contacts, id: :uuid do |t|
      t.references :shipment, type: :uuid, index: true, null: false
      t.references :sandbox, foreign_key: { to_table: :tenants_sandboxes }, type: :uuid, index: true
      t.integer :contact_type
      t.float :latitude
      t.float :longitude
      t.string :company_name
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.string :geocoded_address
      t.string :street
      t.string :street_number
      t.string :post_code
      t.string :city
      t.string :province
      t.string :premise
      t.string :country_code
      t.string :country_name
      t.timestamps
    end
  end
end
