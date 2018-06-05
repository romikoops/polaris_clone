# frozen_string_literal: true

class CreateItineraries < ActiveRecord::Migration[5.1]
  def change
    create_table :itineraries, &:timestamps
  end
end
