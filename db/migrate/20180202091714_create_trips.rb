# frozen_string_literal: true

class CreateTrips < ActiveRecord::Migration[5.1]
  def change
    create_table :trips do |t|
      t.integer :itinerary_id
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
    add_column :layovers, :trip_id, :integer
  end
end
