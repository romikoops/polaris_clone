# frozen_string_literal: true

class BackfillTransitTimes < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute("
        WITH unique_trips as (
          SELECT DISTINCT ON (tenant_vehicle_id, itinerary_id) tenant_vehicle_id, itinerary_id, start_date, end_date
          FROM  trips
          JOIN itineraries ON itineraries.id = trips.itinerary_id
          JOIN tenant_vehicles ON tenant_vehicles.id = trips.tenant_vehicle_id
        )
        INSERT INTO legacy_transit_times(itinerary_id, tenant_vehicle_id, duration, created_at, updated_at)
             SELECT unique_trips.itinerary_id,
                    unique_trips.tenant_vehicle_id,
                    DATE_PART('day', unique_trips.start_date - unique_trips.end_date),
                    current_timestamp,
                    current_timestamp
             FROM unique_trips
            ")
    end
  end
end
