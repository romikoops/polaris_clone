# frozen_string_literal: true

class RemoveTotalPriceFromShipments < ActiveRecord::Migration[5.1]
  def change
    remove_column :shipments, :total_price, :jsonb
  end
end
