class BackfillHubIdsOnItineraries < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute("
        WITH origin_stops as (
          SELECT * from stops
          WHERE stops.index = 0
        ), destination_stops as (
          SELECT * from stops
          WHERE stops.index = 1
        )
        UPDATE itineraries
        SET
          origin_hub_id = origin_stops.hub_id,
          destination_hub_id = destination_stops.hub_id
        FROM origin_stops, destination_stops
        WHERE itineraries.id = origin_stops.itinerary_id
        AND itineraries.id = destination_stops.itinerary_id
        AND origin_stops.itinerary_id = destination_stops.itinerary_id
        ")
    end
  end

  def down
  end
end
