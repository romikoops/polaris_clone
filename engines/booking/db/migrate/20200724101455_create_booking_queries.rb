# frozen_string_literal: true

class CreateBookingQueries < ActiveRecord::Migration[5.2]
  def change
    create_table :booking_queries, id: :uuid do |t|
      t.references :organization, foreign_key: {to_table: :organizations_organizations}, type: :uuid
      t.references :customer, foreign_key: {to_table: :users_users}, type: :uuid
      t.references :creator, foreign_key: {to_table: :users_users}, type: :uuid
      t.references :company, foreign_key: {to_table: :companies_companies}, type: :uuid
      t.datetime :desired_start_date
      t.references :origin, polymorphic: true, type: :uuid
      t.references :destination, polymorphic: true, type: :uuid
      t.references :legacy_origin, polymorphic: true, index: {name: "index_booking_queries_on_legacy_origin"}
      t.references :legacy_destination, polymorphic: true, index: {name: "index_booking_queries_on_legacy_destination"}
      t.integer :category
      t.timestamps
    end
  end
end
