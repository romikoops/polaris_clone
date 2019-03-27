# frozen_string_literal: true

class AddIndexToTruckingLocationsLocationId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_locations, :location_id, algorithm: :concurrently
  end
end
