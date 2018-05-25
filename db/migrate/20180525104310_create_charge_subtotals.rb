class CreateChargeSubtotals < ActiveRecord::Migration[5.1]
  def change
    create_table :charge_subtotals do |t|
      t.integer :price_id
      t.integer :charge_category_id
      t.integer :charge_breakdown_id

      t.timestamps
    end
  end
end
