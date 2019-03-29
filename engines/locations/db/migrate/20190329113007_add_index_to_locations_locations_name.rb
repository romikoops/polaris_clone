# frozen_string_literal: true

class AddIndexToLocationsLocationsName < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :locations_locations, :name, algorithm: :concurrently
  end
end
