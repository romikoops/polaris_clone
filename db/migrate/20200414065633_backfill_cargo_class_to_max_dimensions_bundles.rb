# frozen_string_literal: true

class BackfillCargoClassToMaxDimensionsBundles < ActiveRecord::Migration[5.2]
  def up
    exec_update <<~SQL
      UPDATE max_dimensions_bundles
      SET cargo_class = 'lcl'
    SQL
  end
end
