# frozen_string_literal: true

class AddIndexToLocodes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :locations_names, :locode, algorithm: :concurrently
  end
end
