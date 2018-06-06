# frozen_string_literal: true

class AddItineraryToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :itinerary_id, :integer
  end
end
