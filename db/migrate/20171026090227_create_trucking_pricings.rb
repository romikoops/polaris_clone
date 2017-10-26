class CreateTruckingPricings < ActiveRecord::Migration[5.1]
  def change
    create_table :trucking_pricings do |t|
    	t.integer :trucker_id
      t.decimal :price_fix
      t.decimal :price_per_km
      t.decimal :price_per_ton
      t.decimal :price_per_m3
      t.float :fcl_limit_m3_40_foot, default: 70.0
      t.float :fcl_limit_tons_40_foot, default: 24.0
      t.decimal :fcl_price, default: 3095.0
      t.decimal :steptable_min_price, default: 217.0
      t.jsonb :steptable
      t.string :currency, default: "USD"
      t.timestamps
    end
  end
end
