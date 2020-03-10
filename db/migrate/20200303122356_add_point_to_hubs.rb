# frozen_string_literal: true

class AddPointToHubs < ActiveRecord::Migration[5.2]
  def change
    add_column :hubs, :point, :geometry
  end
end
