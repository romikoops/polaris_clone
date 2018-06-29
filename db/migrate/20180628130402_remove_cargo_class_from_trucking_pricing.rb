class RemoveCargoClassFromTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    remove_column :trucking_pricings, :cargo_class, :string
  end
end
