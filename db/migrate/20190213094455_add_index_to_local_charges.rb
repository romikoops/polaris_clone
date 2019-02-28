# frozen_string_literal: true

class AddIndexToLocalCharges < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :local_charges, :uuid, unique: true, algorithm: :concurrently
  end
end
