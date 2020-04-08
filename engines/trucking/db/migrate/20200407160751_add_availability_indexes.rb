# frozen_string_literal: true

class AddAvailabilityIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_type_availabilities, :query_method, algorithm: :concurrently
    add_index :trucking_type_availabilities, :truck_type, algorithm: :concurrently
    add_index :trucking_type_availabilities, :load_type, algorithm: :concurrently
    add_index :trucking_hub_availabilities, :type_availability_id, algorithm: :concurrently
    add_index :trucking_hub_availabilities, :hub_id, algorithm: :concurrently
  end
end
