class CreateVesselSchedules < ActiveRecord::Migration[5.1]
  def change
    create_table :vessel_schedules do |t|
    	t.string :vessel
      t.string :voyage_code
      
      t.string :from
      t.string :to

      t.datetime :ets
      t.datetime :eta
      t.timestamps
    end
  end
end
