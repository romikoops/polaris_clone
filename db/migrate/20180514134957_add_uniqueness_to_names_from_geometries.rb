# frozen_string_literal: true

class AddUniquenessToNamesFromGeometries < ActiveRecord::Migration[5.1]
  def change
    add_index :geometries, %i[name_1 name_2 name_3 name_4], unique: true
  end
end
