# frozen_string_literal: true

class CreateLedgerBookRates < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_book_rates, id: false do |t|
      t.references :book, type: :uuid, index: false, null: false
      t.references :rate, type: :uuid, index: false, null: false
      t.index %i[book_id rate_id]
      t.index %i[rate_id book_id]
    end
  end
end
