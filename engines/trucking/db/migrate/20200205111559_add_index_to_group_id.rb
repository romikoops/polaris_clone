# frozen_string_literal: true

class AddIndexToGroupId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_truckings, :group_id, algorithm: :concurrently
  end
end
