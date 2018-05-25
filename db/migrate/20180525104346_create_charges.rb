class CreateCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :charges do |t|
      t.integer :price_id
      t.string :name
      t.string :code
      t.integer :charge_category_id
      t.integer :charge_breakdown_id

      t.timestamps
    end
  end
end
