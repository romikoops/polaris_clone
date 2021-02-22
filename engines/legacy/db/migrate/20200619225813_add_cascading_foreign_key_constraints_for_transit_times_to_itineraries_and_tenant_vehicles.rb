# frozen_string_literal: true
class AddCascadingForeignKeyConstraintsForTransitTimesToItinerariesAndTenantVehicles < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :legacy_transit_times, :itineraries, on_delete: :cascade, validate: false
    add_foreign_key :legacy_transit_times, :tenant_vehicles, on_delete: :cascade, validate: false
  end
end
