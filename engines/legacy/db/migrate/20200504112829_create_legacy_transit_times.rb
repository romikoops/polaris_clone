# frozen_string_literal: true

class CreateLegacyTransitTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_transit_times, id: :uuid do |t|
      t.integer :tenant_vehicle_id, index: true
      t.integer :itinerary_id, index: true
      t.integer :duration
      t.timestamps
    end
    add_foreign_key :legacy_transit_times, :tenant_vehicles, table: :legacy_tenant_vehicles, validate: false
    add_foreign_key :legacy_transit_times, :itineraries, table: :legacy_itineraries, validate: false
  end
end
