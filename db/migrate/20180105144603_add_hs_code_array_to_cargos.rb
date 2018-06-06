# frozen_string_literal: true

class AddHsCodeArrayToCargos < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_items, :hs_codes, :string, array: true, default: []
    add_column :containers, :hs_codes, :string, array: true, default: []
  end
end
