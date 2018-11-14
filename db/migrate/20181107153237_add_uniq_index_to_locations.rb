# frozen_string_literal: true

class AddUniqIndexToLocations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :locations, %i(postal_code suburb neighbourhood city province country), unique: true, algorithm: :concurrently, name: 'uniq_index'
  end
end
