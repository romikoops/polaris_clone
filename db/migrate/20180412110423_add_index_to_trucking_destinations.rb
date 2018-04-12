class AddIndexToTruckingDestinations < ActiveRecord::Migration[5.1]
  def change
    add_index :trucking_destination, :zipcode
    add_index :trucking_destination, :country_code
    add_index :trucking_destination, :city_name
    add_index :trucking_destination, :distance
  end
end
