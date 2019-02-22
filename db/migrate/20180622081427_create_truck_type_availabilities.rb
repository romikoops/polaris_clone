# frozen_string_literal: true

class CreateTruckTypeAvailabilities < ActiveRecord::Migration[5.1]
  def change
    create_table :truck_type_availabilities do |t|
      t.string :load_type
      t.string :carriage
      t.string :truck_type

      t.timestamps
    end
  end
end
