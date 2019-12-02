# frozen_string_literal: true

class UpdateColumns < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      remove_column :cargo_units, :dangerous_goods
      add_column :cargo_units, :dangerous_goods, :integer, default: 0
      add_monetize :cargo_units, :goods_value, currency: { default: nil }
      add_monetize :cargo_cargos, :total_goods_value, currency: { default: nil }
    end
  end

  def down
    safety_assured do
      remove_column :cargo_units, :dangerous_goods
      add_column :cargo_units, :dangerous_goods, :boolean, default: false
      remove_monetize :cargo_units, :goods_value
      remove_monetize :cargo_cargos, :total_goods_value
    end
  end
end
