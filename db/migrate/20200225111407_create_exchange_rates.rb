# frozen_string_literal: true

class CreateExchangeRates < ActiveRecord::Migration[5.2]
  def change
    create_table :exchange_rates do |t|
      t.string :from, index: true
      t.string :to, index: true
      t.decimal :rate
      t.timestamps
    end
  end
end
