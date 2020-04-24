# frozen_string_literal: true

class BackfillMaxDimensionsBundles < ActiveRecord::Migration[5.2]
  def up
    exec_update <<~SQL
      UPDATE max_dimensions_bundles
      SET dimension_x = COALESCE(NULLIF(dimension_x, 0), 590),
          dimension_y = COALESCE(NULLIF(dimension_y, 0), 590),
          dimension_z = COALESCE(NULLIF(dimension_z, 0), 590),
          payload_in_kg = COALESCE(NULLIF(payload_in_kg, 0), 40000),
      WHERE max_dimensions_bundles.cargo_class = 'lcl'
    SQL
  end

  def down; end
end
