# frozen_string_literal: true

class AddCustomsToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :customs, :jsonb
  end
end
