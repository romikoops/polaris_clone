class AddDirectionToTruckingPricings < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_pricings, :direction, :string
  end
end
