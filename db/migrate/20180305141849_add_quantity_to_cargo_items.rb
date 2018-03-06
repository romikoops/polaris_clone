class AddQuantityToCargoItems < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_items, :quantity, :integer
  end
end
