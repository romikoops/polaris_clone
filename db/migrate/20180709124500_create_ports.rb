# frozen_string_literal: true

class CreatePorts < ActiveRecord::Migration[5.1]
  def change
    create_table :ports do |t|
      t.integer :country_id
      t.string :name
      t.decimal :latitude
      t.decimal :longitude
      t.string :telephone
      t.string :web
      t.string :code
      t.integer :nexus_id
      t.integer :location_id
      t.timestamps
    end
  end
end
