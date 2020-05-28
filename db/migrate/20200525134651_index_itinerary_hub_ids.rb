class IndexItineraryHubIds < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :itineraries, :origin_hub_id, algorithm: :concurrently
    add_index :itineraries, :destination_hub_id, algorithm: :concurrently
  end
end
