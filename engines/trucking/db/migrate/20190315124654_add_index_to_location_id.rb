# frozen_string_literal: true

class AddIndexToLocationId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_truckings, :location_id, algorithm: :concurrently
  end
end
