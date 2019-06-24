# frozen_string_literal: true

class CreateLegacyItineraries < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_itineraries, id: :uuid, &:timestamps
  end
end
