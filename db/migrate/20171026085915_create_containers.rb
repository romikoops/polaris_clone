class CreateContainers < ActiveRecord::Migration[5.1]
  def change
    create_table :containers do |t|
    	t.integer :shipment_id
      t.string :size_class
      t.string :weight_class

      t.decimal :payload_in_kg
      t.decimal :tare_weight
      t.decimal :gross_weight
      t.timestamps
    end
  end
end
