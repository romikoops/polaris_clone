class CreateHubTruckingOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :hub_trucking_options do |t|
      t.integer :hub_id
      t.integer :trucking_option_id
      t.timestamps
    end
  end
end
