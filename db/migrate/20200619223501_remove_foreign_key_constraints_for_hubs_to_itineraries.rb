class RemoveForeignKeyConstraintsForHubsToItineraries < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :itineraries, column: :origin_hub_id
    remove_foreign_key :itineraries, column: :destination_hub_id
  end

  def down
  end
end
