# frozen_string_literal: true

class AddDeletedAtToShipments < ActiveRecord::Migration[5.2]
  def change
    add_column :shipments, :deleted_at, :datetime, index: true
  end
end
