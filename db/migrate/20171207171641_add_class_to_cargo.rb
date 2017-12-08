class AddClassToCargo < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_items, :cargo_class, :string
    add_column :containers, :cargo_class, :string
  end
end
