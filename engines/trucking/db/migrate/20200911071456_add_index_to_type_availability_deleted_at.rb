# frozen_string_literal: true
class AddIndexToTypeAvailabilityDeletedAt < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_type_availabilities, :deleted_at, algorithm: :concurrently
  end
end
