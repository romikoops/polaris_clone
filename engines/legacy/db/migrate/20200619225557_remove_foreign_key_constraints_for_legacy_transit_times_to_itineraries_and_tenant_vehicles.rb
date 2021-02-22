# frozen_string_literal: true
class RemoveForeignKeyConstraintsForLegacyTransitTimesToItinerariesAndTenantVehicles < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :legacy_transit_times, :itineraries
    remove_foreign_key :legacy_transit_times, :tenant_vehicles
  end

  def down
  end
end
