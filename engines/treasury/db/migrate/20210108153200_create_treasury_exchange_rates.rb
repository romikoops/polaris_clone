# frozen_string_literal: true
class CreateTreasuryExchangeRates < ActiveRecord::Migration[5.2]
  def change
    create_table :treasury_exchange_rates, id: :uuid do |t|
      t.string :from, index: true
      t.string :to, index: true
      t.decimal :rate
      t.timestamps
    end
    add_index :treasury_exchange_rates, :created_at
  end
end
