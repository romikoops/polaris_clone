# frozen_string_literal: true

class AddMotScopeIdToItinerary < ActiveRecord::Migration[5.1]
  def change
    add_column :itineraries, :mot_scope_id, :integer
  end
end
