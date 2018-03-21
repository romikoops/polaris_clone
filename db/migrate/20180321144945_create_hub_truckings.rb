class CreateHubTruckings < ActiveRecord::Migration[5.1]
  def change
    create_table :hub_truckings do |t|
      t.integer :hub_id
      t.integer :trucking_destination_id
      t.integer :courier_id
      t.integer :trucking_pricing
      t.string :load_type
      t.timestamps
    end
    remove_column :trucking_pricings, :hub_id, :integer
    remove_column :trucking_pricings, :trucking_destination_id, :integer
    remove_column :trucking_pricings, :courier_id, :integer
    remove_column :trucking_pricings, :fees, :jsonb
    add_column :trucking_pricings, :export, :jsonb
    add_column :trucking_pricings, :import, :jsonb
    add_column :trucking_pricings, :courier_id, :integer
  end
end
