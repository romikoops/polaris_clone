# frozen_string_literal: true

class CreateVehicles < ActiveRecord::Migration[5.1]
  def change
    create_table :vehicles do |t|
      t.string :name
      t.string :mode_of_transport
      t.timestamps
    end
  end
end
