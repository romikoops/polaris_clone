class AddChargeableWeightToCargoItem < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_items, :chargeable_weight, :decimal
  end
end
