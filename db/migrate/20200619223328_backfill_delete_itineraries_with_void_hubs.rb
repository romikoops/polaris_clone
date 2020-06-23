class BackfillDeleteItinerariesWithVoidHubs < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      Itinerary.left_joins(:origin_hub)
        .where(hubs: {id: nil})
        .where.not(itineraries: {origin_hub_id: nil})
        .destroy_all

      Itinerary.left_joins(:destination_hub)
        .where(hubs: {id: nil})
        .where.not(itineraries: {destination_hub_id: nil})
        .destroy_all
    end
  end

  def down
  end
end
