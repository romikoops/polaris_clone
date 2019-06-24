# frozen_string_literal: true

class CreateLegacyStops < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_stops, id: :uuid , &:timestamps
  end
end
