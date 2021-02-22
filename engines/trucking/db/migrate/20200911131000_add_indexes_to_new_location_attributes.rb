# frozen_string_literal: true
class AddIndexesToNewLocationAttributes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_locations, :data, algorithm: :concurrently
    add_index :trucking_locations, :query, algorithm: :concurrently
  end
end
