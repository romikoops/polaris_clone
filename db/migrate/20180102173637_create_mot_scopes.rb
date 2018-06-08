# frozen_string_literal: true

class CreateMotScopes < ActiveRecord::Migration[5.1]
  def change
    create_table :mot_scopes do |t|
      t.boolean :ocean_container
      t.boolean :ocean_cargo_item
      t.boolean :air_container
      t.boolean :air_cargo_item
      t.boolean :rail_container
      t.boolean :rail_cargo_item

      t.timestamps
    end
  end
end
