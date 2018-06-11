# frozen_string_literal: true

class ConvertShipmentTotlaToHash < ActiveRecord::Migration[5.1]
  def change
    remove_column :shipments, :total_price, :integer
    add_column :shipments, :total_price, :jsonb
  end
end
