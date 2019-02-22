# frozen_string_literal: true

class AddTripIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :trips, :tenant_vehicle_id, algorithm: :concurrently
    add_index :trips, :closing_date, algorithm: :concurrently
    add_index :trips, :itinerary_id, algorithm: :concurrently
  end
end
