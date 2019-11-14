# frozen_string_literal: true

class CreateShipmentsUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :shipments_units, id: :uuid do |t|
      t.references :sandbox, foreign_key: { to_table: :tenants_sandboxes }, type: :uuid, index: true
      t.references :cargo, type: :uuid, index: true, null: false
      t.monetize :goods_value, currency: { default: nil }
      t.integer :quantity, null: false
      t.bigint :cargo_class
      t.bigint :cargo_type
      t.boolean :stackable
      t.integer :dangerous_goods, default: 0

      t.decimal :weight_value, precision: 100, scale: 3
      t.string :weight_unit, default: 'kg'

      t.decimal :width_value, precision: 100, scale: 4
      t.string :width_unit, default: 'm'

      t.decimal :length_value, precision: 100, scale: 4
      t.string :length_unit, default: 'm'

      t.decimal :height_value, precision: 100, scale: 4
      t.string :height_unit, default: 'm'

      t.decimal :volume_value, precision: 100, scale: 6
      t.string :volume_unit, default: 'm3'

      t.timestamps
    end
  end
end
