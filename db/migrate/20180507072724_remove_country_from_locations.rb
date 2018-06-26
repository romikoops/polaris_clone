# frozen_string_literal: true

class RemoveCountryFromLocations < ActiveRecord::Migration[5.1]
  def change
    remove_column :locations, :country, :string
  end
end
