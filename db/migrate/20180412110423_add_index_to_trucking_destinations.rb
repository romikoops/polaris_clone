class AddIndexToTruckingDestinations < ActiveRecord::Migration[5.1]
  def change
    add_index :trucking_destinations, :zipcode
    add_index :trucking_destinations, :country_code
    add_index :trucking_destinations, :city_name
    add_index :trucking_destinations, :distance
  end
end
