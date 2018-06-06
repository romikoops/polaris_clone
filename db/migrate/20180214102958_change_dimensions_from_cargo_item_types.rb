# frozen_string_literal: true

class ChangeDimensionsFromCargoItemTypes < ActiveRecord::Migration[5.1]
  def change
    change_column :cargo_item_types, :dimension_x, :decimal
    change_column :cargo_item_types, :dimension_y, :decimal
  end
end
