# frozen_string_literal: true

class AddIndexToMaxDimensionsLoadType < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :max_dimensions_bundles, :cargo_class, algorithm: :concurrently
  end
end
