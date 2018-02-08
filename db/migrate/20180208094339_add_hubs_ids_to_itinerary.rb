class AddHubsIdsToItinerary < ActiveRecord::Migration[5.1]
  def change
    add_column :itineraries, :hubs, :jsonb, array: true, default: []
  end
end
