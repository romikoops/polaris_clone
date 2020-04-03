# frozen_string_literal: true

class AddingTranshipmentToItinerary < ActiveRecord::Migration[5.2]
  def change
    add_column :itineraries, :transshipment, :string
  end
end
