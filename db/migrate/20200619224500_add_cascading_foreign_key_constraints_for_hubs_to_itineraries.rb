class AddCascadingForeignKeyConstraintsForHubsToItineraries < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :itineraries, :hubs, column: :origin_hub_id, on_delete: :cascade, validate: false
    add_foreign_key :itineraries, :hubs, column: :destination_hub_id, on_delete: :cascade, validate: false
  end
end
