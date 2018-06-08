# frozen_string_literal: true

class CreateCargoItems < ActiveRecord::Migration[5.1]
  def change
    create_table :cargo_items do |t|
      t.integer :shipment_id
      t.decimal :payload_in_kg
      t.decimal :dimension_x
      t.decimal :dimension_y
      t.decimal :dimension_z
      t.timestamps
    end
  end
end
