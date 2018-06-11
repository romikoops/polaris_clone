# frozen_string_literal: true

class CreateHubTruckings < ActiveRecord::Migration[5.1]
  def change
    create_table :hub_truckings do |t|
      t.integer :hub_id
      t.integer :trucking_destination_id
      t.integer :trucking_pricing_id
      t.timestamps
    end
  end
end
