# frozen_string_literal: true

class CreateAddressBookContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :address_book_contacts, id: :uuid do |t|
      t.references :user, foreign_key: { to_table: :tenants_users }, type: :uuid, index: true
      t.references :sandbox, foreign_key: { to_table: :tenants_sandboxes }, type: :uuid, index: true

      t.string :company_name
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.geometry :point
      t.string :geocoded_address
      t.string :street
      t.string :street_number
      t.string :postal_code
      t.string :city
      t.string :province
      t.string :premise
      t.string :country_code
      t.timestamps
    end
  end
end
