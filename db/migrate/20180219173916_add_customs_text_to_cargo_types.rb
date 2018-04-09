class AddCustomsTextToCargoTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_items, :customs_text, :string
    add_column :containers, :customs_text, :string
  end
end
