class AddHubIdsToItinerary < ActiveRecord::Migration[5.2]
  def change
    add_reference :itineraries, :origin_hub, foreign_key: {to_table: :hubs}, index: false
    add_reference :itineraries, :destination_hub, foreign_key: {to_table: :hubs}, index: false
  end
end
