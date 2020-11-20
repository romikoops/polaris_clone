# frozen_string_literal: true

class ChangeTypeOfTotalGoodsValueFromShipments < ActiveRecord::Migration[5.1]
  def change
    change_column :shipments, :total_goods_value, "decimal USING CAST(total_goods_value AS decimal)"
  end
end
