# frozen_string_literal: true

class RemoveDestinationIdFromShipments < ActiveRecord::Migration[5.1]
  def change
    remove_column :shipments, :destination_id, :integer
  end
end
