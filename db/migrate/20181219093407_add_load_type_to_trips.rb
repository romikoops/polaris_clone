# frozen_string_literal: true

class AddLoadTypeToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :load_type, :string
  end
end
