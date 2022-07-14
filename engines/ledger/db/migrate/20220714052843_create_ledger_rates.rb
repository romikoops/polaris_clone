# frozen_string_literal: true

class CreateLedgerRates < ActiveRecord::Migration[5.2]
  def change
    create_enum :rate_basis_list, Ledger::Rate::RATE_BASIS_LIST

    create_table :ledger_rates, id: :uuid do |t|
      t.references :book_routing, type: :uuid, index: true, null: false
      t.daterange :validity, null: false
      t.string :rate_currency, null: false
      t.integer :rate_cents, null: false
      t.string :min_currency
      t.integer :min_cents
      t.string :max_currency
      t.integer :max_cents
      t.enum :rate_basis, enum_type: :rate_basis_list
      t.numrange :kg_range
      t.numrange :cbm_range
      t.numrange :wm_range
      t.numrange :density_range
      t.numrange :km_range
      t.numrange :unit_range
      t.string :fee_code, null: false
      t.string :fee_name, null: false
      t.references :group, type: :uuid, index: true, foreign_key: { to_table: "groups_groups" }

      t.timestamps
    end
  end
end
