# frozen_string_literal: true

class RemoveQuoteIdFromShipments < ActiveRecord::Migration[5.2]
  def change
    remove_column :shipments, :quote_id, :integer
  end
end
