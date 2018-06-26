# frozen_string_literal: true

class CreateCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :charges do |t|
      t.integer :parent_id
      t.integer :price_id
      t.integer :charge_category_id
      t.integer :children_charge_category_id
      t.integer :charge_breakdown_id
      t.integer :detail_level

      t.timestamps
    end
  end
end
