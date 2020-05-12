# frozen_string_literal: true

class RenameDimensionsToWidthLengthHeight < ActiveRecord::Migration[5.2]
  def up
    add_column :cargo_item_types, :width, :decimal
    add_column :cargo_item_types, :length, :decimal
    add_column :cargo_items, :width, :decimal
    add_column :cargo_items, :length, :decimal
    add_column :cargo_items, :height, :decimal
    add_column :max_dimensions_bundles, :width, :decimal
    add_column :max_dimensions_bundles, :length, :decimal
    add_column :max_dimensions_bundles, :height, :decimal
  end
end
