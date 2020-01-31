# frozen_string_literal: true

class AddIndexToShipmentsTenderId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :shipments, :tender_id, algorithm: :concurrently
  end
end
