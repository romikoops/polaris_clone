# frozen_string_literal: true

class CreateLedgerBookRoutings < ActiveRecord::Migration[5.2]
  def change
    create_enum :book_routing_types, Ledger::BookRouting::TYPES

    create_table :ledger_book_routings, id: :uuid do |t|
      t.references :book, type: :uuid, index: true, null: false
      t.references :routing, type: :uuid, index: true, null: false
      t.references :service, type: :uuid, null: false
      t.enum :type, enum_type: :book_routing_types, null: false

      t.timestamps
    end
  end
end
