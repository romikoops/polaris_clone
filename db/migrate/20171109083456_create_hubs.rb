# frozen_string_literal: true

class CreateHubs < ActiveRecord::Migration[5.1]
  def change
    create_table :hubs do |t|
      t.integer :tenant_id
      t.integer :location_id
      t.string :name
      t.string :hub_type
      t.float :latitude
      t.float :longitude
      t.string :hub_status, default: "active"
      t.string :hub_code
      t.timestamps
    end
  end
end
