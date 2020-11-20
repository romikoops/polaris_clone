# frozen_string_literal: true

class CreateNewLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.string :postal_code
      t.string :suburb
      t.string :neighbourhood
      t.string :city
      t.string :province
      t.string :country
      t.string :admin_level
      t.geometry :bounds, limit: {srid: 0, type: "geometry"}
    end
  end
end
