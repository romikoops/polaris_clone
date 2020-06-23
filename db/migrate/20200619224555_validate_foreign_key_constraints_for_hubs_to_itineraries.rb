class ValidateForeignKeyConstraintsForHubsToItineraries < ActiveRecord::Migration[5.2]
  def change
    validate_foreign_key :itineraries, {column: :origin_hub_id, on_delete: :cascade}
    validate_foreign_key :itineraries, {column: :destination_hub_id, on_delete: :cascade}
  end
end
