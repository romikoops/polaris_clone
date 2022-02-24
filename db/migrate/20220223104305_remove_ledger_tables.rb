# frozen_string_literal: true

class RemoveLedgerTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :ledger_fees, id: :uuid do |t|
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
    drop_table :ledger_rates, id: :uuid do |t|
      t.references :target, polymorphic: true, type: :uuid, index: { name: "ledger_rate_target_index" }
      t.uuid :location_id, index: true
      t.uuid :terminal_id, index: true
      t.uuid :tenant_id, index: true
      t.timestamps
    end
    drop_table :ledger_delta, id: :uuid do |t|
      t.monetize :amount, amount: { limit: 8 }, currency: { default: nil }
      t.uuid :fee_id, index: true
      t.integer :rate_basis, default: 0, null: false
      t.numrange :kg_range
      t.numrange :stowage_range
      t.numrange :km_range
      t.numrange :cbm_range
      t.numrange :wm_range
      t.numrange :unit_range
      t.monetize :min_amount, amount: { limit: 8 }, currency: { default: nil }
      t.monetize :max_amount, amount: { limit: 8 }, currency: { default: nil }
      t.decimal :wm_ratio, default: 1000
      t.integer :operator, default: 0, null: false
      t.integer :level, default: 0, null: false
      t.references :target, polymorphic: true, type: :uuid, index: { name: "ledger_delta_target_index" }
      t.daterange :validity
      t.timestamps
    end
  end
end
