class CreateTruckingTruckings < ActiveRecord::Migration[5.2]
  def change
    create_table :trucking_truckings, id: :uuid do |t|
      t.integer "hub_id"
      t.uuid "location_id"
      t.uuid "rate_id"
      t.index ["hub_id"], name: "index_trucking_truckings_on_hub_id"
      t.index ["rate_id", "location_id", "hub_id"], name: "trucking_foreign_keys", unique: true
      t.timestamps
    end
  end
end
