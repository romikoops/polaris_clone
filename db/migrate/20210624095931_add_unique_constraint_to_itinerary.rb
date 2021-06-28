# frozen_string_literal: true

class AddUniqueConstraintToItinerary < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :itineraries, :upsert_id,
      unique: true,
      algorithm: :concurrently,
      name: "itinerary_upsert"
  end
end
