class CreateShipments < ActiveRecord::Migration[5.1]
  def change
    create_table :shipments do |t|
    	t.integer :shipper_id
      t.integer :consignee_id
      t.integer :tenant_id
      t.string :load_type
      t.string :hs_code
      t.string :cargo_notes
      t.string :total_goods_value

      t.datetime :planned_pickup_date
      t.integer :origin_id
      t.integer :destination_id
      t.integer :route_id

      t.boolean :has_pre_carriage
      t.boolean :has_on_carriage
      t.decimal :pre_carriage_distance_km
      t.decimal :on_carriage_distance_km

      t.string :haulage
      t.decimal :total_price

      t.string :status
      t.string :imc_reference
      t.string :uuid
      t.timestamps
    end
    add_index :shipments, :load_type
  end
end
