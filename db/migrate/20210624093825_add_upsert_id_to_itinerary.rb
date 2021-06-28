# frozen_string_literal: true

class AddUpsertIdToItinerary < ActiveRecord::Migration[5.2]
  def change
    add_column :itineraries, :upsert_id, :uuid
  end
end
