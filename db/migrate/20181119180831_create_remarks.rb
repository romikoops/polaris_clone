# frozen_string_literal: true

class CreateRemarks < ActiveRecord::Migration[5.2]
  def change
    create_table :remarks do |t|
      t.references :tenant, foreign_key: true
      t.string :category
      t.string :subcategory
      t.string :body

      t.timestamps
    end
  end
end
