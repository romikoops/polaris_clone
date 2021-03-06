# frozen_string_literal: true
class AddIndexToTruckingLocationDeletedAt < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_locations, :deleted_at, algorithm: :concurrently
  end
end
