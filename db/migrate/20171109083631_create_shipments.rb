# frozen_string_literal: true

class CreateShipments < ActiveRecord::Migration[5.1]
  def change
    create_table :shipments do |t|
      t.integer :shipper_id
      t.integer :shipper_location_id
      t.integer :origin_id
      t.integer :destination_id
      t.integer :route_id
      t.string :uuid
      t.string :imc_reference

      t.string :status

      t.string :load_type

      t.datetime :planned_pickup_date

      t.boolean :has_pre_carriage
      t.decimal :pre_carriage_distance_km

      t.boolean :has_on_carriage
      t.decimal :on_carriage_distance_km

      t.decimal :total_price
      t.string :total_goods_value
      t.string :cargo_notes

      t.string :haulage
      t.string :hs_code, default: [], array: true

      t.integer :schedule_set, default: [], array: true
      t.jsonb :generated_fees
      t.timestamps
    end
  end
end
