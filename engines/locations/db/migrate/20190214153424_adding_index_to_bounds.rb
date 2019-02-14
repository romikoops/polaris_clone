class AddingIndexToBounds < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :locations_locations, :bounds, using: :gist, algorithm: :concurrently
  end
end
