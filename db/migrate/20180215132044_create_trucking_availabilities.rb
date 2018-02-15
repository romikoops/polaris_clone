class CreateTruckingAvailabilities < ActiveRecord::Migration[5.1]
  def change
    create_table :trucking_availabilities do |t|
        t.boolean :cargo_item
        t.boolean :container
      t.timestamps
    end
    add_column :hubs, :trucking_availability_id, :integer
  end
end
