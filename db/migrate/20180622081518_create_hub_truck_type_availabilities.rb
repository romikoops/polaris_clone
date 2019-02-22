# frozen_string_literal: true

class CreateHubTruckTypeAvailabilities < ActiveRecord::Migration[5.1]
  def change
    create_table :hub_truck_type_availabilities do |t|
      t.integer :hub_id
      t.integer :truck_type_availability_id

      t.timestamps
    end
  end
end
