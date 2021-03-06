# frozen_string_literal: true

class CreatePrices < ActiveRecord::Migration[5.1]
  def change
    create_table :prices do |t|
      t.decimal :value
      t.string :currency

      t.timestamps
    end
  end
end
