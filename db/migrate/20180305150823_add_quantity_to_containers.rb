class AddQuantityToContainers < ActiveRecord::Migration[5.1]
  def change
    add_column :containers, :quantity, :integer
  end
end
