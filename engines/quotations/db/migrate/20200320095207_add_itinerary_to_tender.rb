# frozen_string_literal: true

class AddItineraryToTender < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_tenders, :itinerary_id, :integer
  end
end
