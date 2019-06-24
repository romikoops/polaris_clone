# frozen_string_literal: true

class AddIndexToShipments < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :itineraries, :name, algorithm: :concurrently
    add_index :itineraries, :mode_of_transport, algorithm: :concurrently
    add_index :itineraries, :tenant_id, algorithm: :concurrently
  end
end
