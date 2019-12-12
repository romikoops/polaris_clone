# frozen_string_literal: true

class CreateLedgerFees < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_fees, id: :uuid do |t|
      t.bigint :cargo_class, default: 0, index: true
      t.bigint :cargo_type, default: 0, index: true
      t.integer :category, default: 0, index: true
      t.string :code
      t.uuid :rate_id, index: true
      t.integer :action, default: 0
      t.decimal :base, default: 0.000001
      t.integer :order, default: 0
      t.integer :applicable, default: 0
      t.decimal :load_meterage_limit, default: 0.0
      t.integer :load_meterage_type, default: 0
      t.integer :load_meterage_logic, default: 0
      t.decimal :load_meterage_ratio, default: 0
      t.timestamps
    end
  end
end
