# frozen_string_literal: true

class AddTruckingTypeToHubs < ActiveRecord::Migration[5.1]
  def change
    add_column :hubs, :trucking_type, :string
    add_column :locations, :province, :string
  end
end
