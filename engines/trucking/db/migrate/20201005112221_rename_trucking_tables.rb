class RenameTruckingTables < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_table :trucking_truckings, :trucking_truckings_20201005
      rename_table :new_trucking_truckings, :trucking_truckings
    end
  end
end
