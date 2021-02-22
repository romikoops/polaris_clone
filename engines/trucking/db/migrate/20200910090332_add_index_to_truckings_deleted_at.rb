# frozen_string_literal: true
class AddIndexToTruckingsDeletedAt < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_truckings, :deleted_at, algorithm: :concurrently
  end
end
