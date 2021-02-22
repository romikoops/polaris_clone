# frozen_string_literal: true
class ValidateForeignKeyConstraintsForLegacyTransitTimesToItinerariesAndTenantVehicles < ActiveRecord::Migration[5.2]
  def change
    validate_foreign_key :legacy_transit_times, to_table: :itineraries, on_delete: :cascade
    validate_foreign_key :legacy_transit_times, to_table: :tenant_vehicles, on_delete: :cascade
  end
end
