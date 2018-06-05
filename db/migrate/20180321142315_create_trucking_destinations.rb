# frozen_string_literal: true

class CreateTruckingDestinations < ActiveRecord::Migration[5.1]
  def change
    create_table :trucking_destinations do |t|
      t.string :zipcode
      t.string :country_code
      t.string :city_name
      t.integer :distance
      t.timestamps
    end
  end
end
