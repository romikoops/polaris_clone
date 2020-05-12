# frozen_string_literal: true

class BackfillRenamedDimensions < ActiveRecord::Migration[5.2]
  def change
    exec_update <<~SQL
      UPDATE cargo_item_types
      SET width = cargo_item_types.dimension_x,
      length = cargo_item_types.dimension_y
    SQL

    exec_update <<~SQL
      UPDATE cargo_items
      SET width = cargo_items.dimension_x,
      length = cargo_items.dimension_y,
      height = cargo_items.dimension_z
    SQL

    exec_update <<~SQL
      UPDATE max_dimensions_bundles
      SET width = max_dimensions_bundles.dimension_x,
      length = max_dimensions_bundles.dimension_y,
      height = max_dimensions_bundles.dimension_z
    SQL
  end
end
