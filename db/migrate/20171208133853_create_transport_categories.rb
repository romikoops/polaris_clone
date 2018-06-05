# frozen_string_literal: true

class CreateTransportCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :transport_categories do |t|
      t.integer :vehicle_id
      t.string :mode_of_transport
      t.string :name
      t.string :cargo_class
      t.timestamps
    end
  end
end
