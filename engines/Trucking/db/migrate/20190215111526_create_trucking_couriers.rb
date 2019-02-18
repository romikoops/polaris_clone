class CreateTruckingCouriers < ActiveRecord::Migration[5.2]
  def change
    create_table :trucking_couriers, id: :uuid do |t|
      t.string "name"
      t.integer "tenant_id"
      t.timestamps
    end
  end
end
