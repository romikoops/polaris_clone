# frozen_string_literal: true

class CreateGeometries < ActiveRecord::Migration[5.1]
  def change
    create_table :geometries do |t|
      t.string :name_1
      t.string :name_2
      t.string :name_3
      t.string :name_4
      t.geometry :data
      t.timestamps
    end
  end
end
