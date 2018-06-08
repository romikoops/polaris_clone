# frozen_string_literal: true

class AddStackableToCargoItems < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_items, :stackable, :boolean, default: true
  end
end
