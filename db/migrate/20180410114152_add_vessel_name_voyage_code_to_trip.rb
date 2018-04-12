class AddVesselNameVoyageCodeToTrip < ActiveRecord::Migration[5.1]
  def change
    add_column :trips, :voyage_code, :string
    add_column :trips, :vessel, :string
  end
end
