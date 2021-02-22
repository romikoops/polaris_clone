# frozen_string_literal: true
class AddVolumeToMaxDimensionsBundles < ActiveRecord::Migration[5.2]
  def up
    add_column :max_dimensions_bundles, :volume, :decimal
    change_column_default :max_dimensions_bundles, :volume, 1000
  end

  def down
    remove_column :max_dimensions_bundles, :volume
  end
end
