# frozen_string_literal: true

class AddIndexForTruckingSpeedup < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :hub_truckings, :hub_id, algorithm: :concurrently
    add_index :trucking_pricings, :trucking_pricing_scope_id, algorithm: :concurrently
    add_index :layovers, :stop_id, algorithm: :concurrently
  end
end
