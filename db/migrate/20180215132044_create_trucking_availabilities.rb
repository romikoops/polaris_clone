class CreateTruckingAvailabilities < ActiveRecord::Migration[5.1]
  def change
    create_table :trucking_availabilities do |t|
        t.boolean :cargo_item, default: false
        t.boolean :container, default: false
      t.timestamps
    end
    add_column :hubs, :trucking_availability_id, :integer
  end
end
