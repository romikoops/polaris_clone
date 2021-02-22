# frozen_string_literal: true
class AddIndexOnDeletedAtToLocations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :locations_locations, :deleted_at, algorithm: :concurrently
  end
end
