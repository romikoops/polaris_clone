# frozen_string_literal: true

class AddColliType < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_items, :cargo_item_type_id, :integer
  end
end
