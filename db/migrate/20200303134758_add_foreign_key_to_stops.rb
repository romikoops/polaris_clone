# frozen_string_literal: true

class AddForeignKeyToStops < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :stops, :itineraries, column: :itinerary_id, validate: false, index: true
  end
end
