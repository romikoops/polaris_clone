# frozen_string_literal: true

class RemoveMotScopeIdFromItineraries < ActiveRecord::Migration[5.1]
  def change
    remove_column :itineraries, :mot_scope_id, :integer
  end
end
