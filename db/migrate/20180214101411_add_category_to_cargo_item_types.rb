class AddCategoryToCargoItemTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_item_types, :category, :string
  end
end
