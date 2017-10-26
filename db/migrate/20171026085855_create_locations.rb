class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
    	t.string :location_type
      t.string :hub_name
      t.string :hub_operator
      t.string :hub_address_details
      t.string :hub_status

      t.float :latitude
      t.float :longitude
      t.string :geocoded_address
      
      t.string :street
      t.string :street_number
      t.string :zip_code
      t.string :city
      t.string :country
      t.timestamps
    end
  end
end
