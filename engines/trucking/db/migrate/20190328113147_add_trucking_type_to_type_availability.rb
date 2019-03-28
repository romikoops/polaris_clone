# frozen_string_literal: true

class AddTruckingTypeToTypeAvailability < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_type_availabilities, :query_method, :integer, index: true
  end
end
