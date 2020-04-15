# frozen_string_literal: true

class AddCargoContentsToContainers < ActiveRecord::Migration[5.2]
  def change
    add_column :containers, :contents, :string
  end
end
