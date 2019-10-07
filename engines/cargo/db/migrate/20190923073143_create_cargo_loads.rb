# frozen_string_literal: true

class CreateCargoLoads < ActiveRecord::Migration[5.2]
  def change
    create_table :cargo_loads, id: :uuid do |t|
      t.uuid :user_id, index: true
      t.uuid :tenant_id, index: true
      t.decimal :weight, default: 0.0
      t.integer :quantity, default: 0
      t.decimal :volume, default: 0.0
      t.bigint :cargo_class, default: 0, index: true
      t.bigint :cargo_type, default: 0, index: true
      t.timestamps
    end
  end
end
