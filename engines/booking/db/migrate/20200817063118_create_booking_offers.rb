# frozen_string_literal: true

class CreateBookingOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :booking_offers, id: :uuid do |t|
      t.references :organization, foreign_key: {to_table: :organizations_organizations}, type: :uuid
      t.references :query, foreign_key: {to_table: :booking_queries}, type: :uuid
      t.references :shipper, foreign_key: {to_table: :users_users}, type: :uuid

      t.timestamps
    end
  end
end
