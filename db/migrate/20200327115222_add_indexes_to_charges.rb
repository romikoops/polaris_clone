# frozen_string_literal: true

class AddIndexesToCharges < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :charges, :charge_category_id, algorithm: :concurrently
    add_index :charges, :children_charge_category_id, algorithm: :concurrently
  end
end
