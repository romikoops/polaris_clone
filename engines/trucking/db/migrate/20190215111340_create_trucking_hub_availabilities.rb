# frozen_string_literal: true

class CreateTruckingHubAvailabilities < ActiveRecord::Migration[5.2]
  def change
    create_table :trucking_hub_availabilities, id: :uuid do |t|
      t.integer "hub_id"
      t.uuid "type_availability_id"
      t.timestamps
    end
  end
end
