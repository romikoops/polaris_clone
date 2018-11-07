class RenameLocationToAddress < ActiveRecord::Migration[5.2]
  def change
    rename_table :locations, :addresses
    rename_column :contacts, :location_id, :address_id
    rename_column :hubs, :location_id, :address_id
    rename_column :ports, :location_id, :address_id
    rename_column :user_locations, :location_id, :address_id

  end
end
