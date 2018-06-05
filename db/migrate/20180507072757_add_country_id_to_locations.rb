# frozen_string_literal: true

class AddCountryIdToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :country_id, :integer
  end
end
