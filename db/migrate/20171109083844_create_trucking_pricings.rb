class CreateTruckingPricings < ActiveRecord::Migration[5.1]
  def change
    create_table :trucking_pricings do |t|
      t.integer :tenant_id
      t.integer :nexus_id

      t.integer :upper_zip
      t.integer :lower_zip
      t.jsonb :rate_table, array: true, default: []
      t.string :currency
      t.timestamps
    end
  end
end
