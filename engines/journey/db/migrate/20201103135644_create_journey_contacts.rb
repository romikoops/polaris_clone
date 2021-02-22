# frozen_string_literal: true
class CreateJourneyContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_contacts, id: :uuid do |t|
      t.references :shipment_request, type: :uuid, index: true,
                                      foreign_key: {on_delete: :cascade, to_table: "journey_shipment_requests"}
      t.uuid :original_id, null: false
      t.string :function, null: false
      t.string :company_name, null: false, default: ""
      t.string :name, null: false
      t.string :phone, null: false, default: ""
      t.string :email, null: false, default: ""
      t.geometry :point, null: false, limit: {srid: 4326}
      t.string :geocoded_address
      t.string :address_line_1, null: false, default: ""
      t.string :address_line_2, null: false, default: ""
      t.string :address_line_3, null: false, default: ""
      t.string :postal_code, null: false, default: ""
      t.string :city, null: false, default: ""
      t.string :country_code, null: false
      t.timestamps
    end

    safety_assured do
      add_presence_constraint :journey_contacts, :company_name
      add_presence_constraint :journey_contacts, :name
      add_presence_constraint :journey_contacts, :phone
      add_presence_constraint :journey_contacts, :email
      add_presence_constraint :journey_contacts, :city
      add_presence_constraint :journey_contacts, :country_code

      add_length_constraint :journey_contacts, :country_code, equal_to: 2
    end
  end
end
