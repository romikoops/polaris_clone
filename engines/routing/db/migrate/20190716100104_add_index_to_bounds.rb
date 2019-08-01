# frozen_string_literal: true

class AddIndexToBounds < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :routing_locations, :bounds, using: :gist, algorithm: :concurrently
  end
end
