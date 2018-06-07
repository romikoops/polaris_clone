# frozen_string_literal: true

class EditShipmentModelForNewScystem < ActiveRecord::Migration[5.1]
  def change
    remove_column :shipments, :total_goods_value, :string
    add_column :shipments, :total_goods_value, :jsonb
    add_column :shipments, :trip_id, :integer
  end
end
