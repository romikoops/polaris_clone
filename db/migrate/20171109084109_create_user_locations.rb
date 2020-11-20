# frozen_string_literal: true

class CreateUserLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :user_locations do |t|
      t.integer :user_id
      t.integer :location_id
      t.string :category
      t.boolean :primary, default: false
      t.timestamps
    end
  end
end
