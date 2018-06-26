# frozen_string_literal: true

class RemoveOriginIdFromShipments < ActiveRecord::Migration[5.1]
  def change
    remove_column :shipments, :origin_id, :integer
  end
end
