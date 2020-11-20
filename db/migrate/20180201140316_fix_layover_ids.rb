# frozen_string_literal: true

class FixLayoverIds < ActiveRecord::Migration[5.1]
  def up
    remove_column :layovers, :interary_id
    add_column :layovers, :itinerary_id, :integer
  end
end
