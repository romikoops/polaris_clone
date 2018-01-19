class CreateCargoItemTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :cargo_item_types do |t|
      t.integer :dimension_x 
      t.integer :dimension_y
      t.string :description
      t.string :area
      t.timestamps
    end
  end
end
