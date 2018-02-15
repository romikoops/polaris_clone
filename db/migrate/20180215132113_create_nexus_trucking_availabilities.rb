class CreateNexusTruckingAvailabilities < ActiveRecord::Migration[5.1]
  def change
    create_table :nexus_trucking_availabilities do |t|
      t.integer :trucking_availability_id
      t.integer :nexus_id
      t.integer :tenant_id
      t.timestamps
    end
  end
end
