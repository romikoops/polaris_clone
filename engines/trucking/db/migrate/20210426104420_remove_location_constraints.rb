# frozen_string_literal: true

class RemoveLocationConstraints < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      execute("ALTER TABLE trucking_locations DROP CONSTRAINT trucking_locations_upsert;")
    end
    remove_index :trucking_locations, name: "index_trucking_locations_on_city_name"
    remove_index :trucking_locations, name: "index_trucking_locations_on_country_code"
    remove_index :trucking_locations, name: "index_trucking_locations_on_distance"
    remove_index :trucking_locations, name: "index_trucking_locations_on_zipcode"
  end
end
