class AddAltTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_pricings, :province, :string
    add_column :trucking_pricings, :city, :string
    add_column :trucking_pricings, :rate_type, :string
    add_column :trucking_pricings, :dist_hub, :string, array: true, default: []
  end
end
