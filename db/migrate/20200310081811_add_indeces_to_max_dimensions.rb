# frozen_string_literal: true

class AddIndecesToMaxDimensions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :max_dimensions_bundles, :mode_of_transport, algorithm: :concurrently
  end
end
