class AddSublocalityToLocation < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :sublocality, :string 
    add_column :trucking_destinations, :geometry, :geometry
  end
end
