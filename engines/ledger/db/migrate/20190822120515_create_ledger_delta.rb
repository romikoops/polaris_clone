# frozen_string_literal: true

class CreateLedgerDelta < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_delta, id: :uuid do |t|
      t.monetize :amount, amount: {limit: 8}, currency: {default: nil}
      t.uuid :fee_id, index: true
      t.integer :rate_basis, default: 0, null: false
      t.numrange :kg_range
      t.numrange :stowage_range
      t.numrange :km_range
      t.numrange :cbm_range
      t.numrange :wm_range
      t.numrange :unit_range
      t.monetize :min_amount, amount: {limit: 8}, currency: {default: nil}
      t.monetize :max_amount, amount: {limit: 8}, currency: {default: nil}
      t.decimal :wm_ratio, default: 1000
      t.integer :operator, default: 0, null: false
      t.integer :level, default: 0, null: false
      t.references :target, polymorphic: true, type: :uuid, index: {name: "ledger_delta_target_index"}
      t.daterange :validity
      t.timestamps
    end
  end
end
