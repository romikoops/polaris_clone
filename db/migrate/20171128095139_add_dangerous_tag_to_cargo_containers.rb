class AddDangerousTagToCargoContainers < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_items, :dangerous_goods, :boolean
    add_column :containers, :dangerous_goods, :boolean
  end
end
