# frozen_string_literal: true

class ValidateTransitTimeForeignKeys < ActiveRecord::Migration[5.2]
  def change
    validate_foreign_key :legacy_transit_times, :tenant_vehicles
    validate_foreign_key :legacy_transit_times, :itineraries
  end
end
