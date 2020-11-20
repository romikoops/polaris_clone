# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :location_type
      t.float :latitude
      t.float :longitude
      t.string :geocoded_address
      t.string :street
      t.string :street_number
      t.string :zip_code
      t.string :city
      t.string :country
      t.string :street_address
      t.timestamps
    end
  end
end
