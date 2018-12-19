# frozen_string_literal: true

class AddLoadTypeToTrips < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :trips, :load_type, :string
    end
  end
end
