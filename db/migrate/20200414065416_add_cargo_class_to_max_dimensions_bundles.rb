# frozen_string_literal: true

class AddCargoClassToMaxDimensionsBundles < ActiveRecord::Migration[5.2]
  def change
    add_column :max_dimensions_bundles, :cargo_class, :string
  end
end
