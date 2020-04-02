# frozen_string_literal: true

class AddingMissingIndecesToTrucking < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_truckings, :load_type, algorithm: :concurrently
    add_index :trucking_truckings, :cargo_class, algorithm: :concurrently
    add_index :trucking_truckings, :carriage, algorithm: :concurrently
  end
end
