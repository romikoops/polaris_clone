class RenameLocationToAddress < ActiveRecord::Migration[5.2]
  def change
    safety_assured { 
      rename_table :locations, :addresses
      rename_table :user_locations, :user_addresses
      rename_column :contacts, :location_id, :address_id
      rename_column :hubs, :location_id, :address_id
      rename_column :ports, :location_id, :address_id
      rename_column :user_addresses, :location_id, :address_id
    }

  end
end
