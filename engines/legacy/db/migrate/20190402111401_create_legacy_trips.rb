# frozen_string_literal: true

class CreateLegacyTrips < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_trips, id: :uuid, &:timestamps
  end
end
