# frozen_string_literal: true

class AddCargoContentsToCargoItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cargo_items, :contents, :string
  end
end
