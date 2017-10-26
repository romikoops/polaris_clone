class CreateTrainSchedules < ActiveRecord::Migration[5.1]
  def change
    create_table :train_schedules do |t|
    	t.string :from
      t.string :to

      t.datetime :etd
      t.datetime :eta
      t.timestamps
    end
  end
end
