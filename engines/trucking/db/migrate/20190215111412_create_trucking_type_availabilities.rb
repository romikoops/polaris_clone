class CreateTruckingTypeAvailabilities < ActiveRecord::Migration[5.2]
  def change
    create_table :trucking_type_availabilities, id: :uuid do |t|
      t.string "load_type"
      t.string "carriage"
      t.string "truck_type"
      t.timestamps
    end
  end
end
