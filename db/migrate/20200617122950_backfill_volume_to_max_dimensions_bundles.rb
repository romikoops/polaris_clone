class BackfillVolumeToMaxDimensionsBundles < ActiveRecord::Migration[5.2]
  def up
    exec_update <<~SQL
      UPDATE max_dimensions_bundles
      SET volume = 1000
      WHERE cargo_class = 'lcl'
    SQL
  end
end
