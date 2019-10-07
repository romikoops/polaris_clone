# frozen_string_literal: true

class CreateCargoGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :cargo_groups, id: :uuid do |t|
      t.uuid :user_id, index: true
      t.uuid :tenant_id, index: true
      t.decimal :weight, default: 0.0
      t.decimal :dimension_x, default: 0.0
      t.decimal :dimension_y, default: 0.0
      t.decimal :dimension_z, default: 0.0
      t.integer :quantity, default: 0
      t.bigint :cargo_class, default: 0, index: true
      t.bigint :cargo_type, default: 0, index: true
      t.boolean :stackable, default: false
      t.boolean :dangerous_goods, default: false
      t.uuid :load_id
      t.timestamps
    end
  end
end
