class AddLoadTypeToTrips < ActiveRecord::Migration[5.2]
  def change
    safety_assured { 
      add_column :trips, :load_type, :string
    }
  end
end
