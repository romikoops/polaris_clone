class CreateTruckingOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :trucking_options do |t|
      t.integer :nexus_id
      t.integer :tenant_id
      t.string :city_name
      t.integer :location_id
      t.timestamps
    end
  end
end
