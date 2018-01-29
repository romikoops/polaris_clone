class AddCargoGroupToCargos < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_items, :cargo_group_id, :string
    add_column :containers, :cargo_group_id, :string
  end
end
