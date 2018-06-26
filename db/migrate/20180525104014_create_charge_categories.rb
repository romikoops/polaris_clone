# frozen_string_literal: true

class CreateChargeCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :charge_categories do |t|
      t.string :name
      t.string :code
      t.integer :cargo_unit_id

      t.timestamps
    end
  end
end
