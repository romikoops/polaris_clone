class CreatePricings < ActiveRecord::Migration[5.1]
  def change
    create_table :pricings do |t|
    	t.integer :customer_id
      t.string :origin_id
      t.string :destination_id

      t.string :currency
      t.decimal :air_m3_ton_price
      t.decimal :lcl_m3_ton_price
      t.decimal :fcl_20f_price
      t.decimal :fcl_40f_price
      t.decimal :fcl_40f_hq_price
      t.datetime :exp_date
      t.string :mode_of_transport
      t.timestamps
    end
  end
end
