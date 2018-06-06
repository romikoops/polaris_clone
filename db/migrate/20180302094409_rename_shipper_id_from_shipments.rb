# frozen_string_literal: true

class RenameShipperIdFromShipments < ActiveRecord::Migration[5.1]
  def change
    rename_column :shipments, :shipper_id, :user_id
  end
end
