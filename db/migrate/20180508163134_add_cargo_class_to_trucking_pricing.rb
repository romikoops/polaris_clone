class AddCargoClassToTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_pricings, :cargo_class, :string
  end
end
