# frozen_string_literal: true

class CreateLayovers < ActiveRecord::Migration[5.1]
  def change
    create_table :layovers do |t|
      t.integer :stop_id
      t.integer :interary_id
      t.datetime :eta
      t.datetime :etd
      t.integer :stop_index
      t.timestamps
    end
  end
end
