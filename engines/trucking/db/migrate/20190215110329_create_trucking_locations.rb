# frozen_string_literal: true

class CreateTruckingLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :trucking_locations, id: :uuid do |t|
      t.string "zipcode"
      t.string "country_code"
      t.string "city_name"
      t.integer "distance"
      t.uuid "location_id"
      t.index ["city_name"], name: "index_trucking_locations_on_city_name"
      t.index ["country_code"], name: "index_trucking_locations_on_country_code"
      t.index ["distance"], name: "index_trucking_locations_on_distance"
      t.index ["zipcode"], name: "index_trucking_locations_on_zipcode"
      t.timestamps
    end
  end
end
