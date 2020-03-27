# frozen_string_literal: true

class AddIndexToChargeCategories < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :charge_categories, :code, algorithm: :concurrently
    add_index :charge_categories, :cargo_unit_id, algorithm: :concurrently
  end
end
