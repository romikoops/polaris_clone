class BackfillDeleteItinerariesWithVoidItinerariesOrTenantVehicles < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      exec_delete(
        <<~SQL
          DELETE FROM
            legacy_transit_times
          WHERE
            id IN (
              SELECT
                legacy_transit_times.id
              FROM
                legacy_transit_times
                LEFT OUTER JOIN itineraries ON itineraries.id = legacy_transit_times.itinerary_id
              WHERE
                itineraries.id IS NULL
            );
        SQL
      )

      exec_delete(
        <<~SQL
          DELETE FROM
            legacy_transit_times
          WHERE
            id IN (
              SELECT
                legacy_transit_times.id
              FROM
                legacy_transit_times
                LEFT OUTER JOIN tenant_vehicles ON tenant_vehicles.id = legacy_transit_times.tenant_vehicle_id
              WHERE
                tenant_vehicles.id IS NULL
            );
        SQL
      )
    end
  end

  def down
  end
end
