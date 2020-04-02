# frozen_string_literal: true

class AddingObviousIndeces < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :stops, :itinerary_id, algorithm: :concurrently
    add_index :stops, :hub_id, algorithm: :concurrently
    add_index :local_charges, :load_type, algorithm: :concurrently
    add_index :local_charges, :direction, algorithm: :concurrently
    add_index :local_charges, :tenant_vehicle_id, algorithm: :concurrently
    add_index :local_charges, :hub_id, algorithm: :concurrently
    add_index :local_charges, :group_id, algorithm: :concurrently
  end
end
