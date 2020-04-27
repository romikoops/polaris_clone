# frozen_string_literal: true

class CreateRatesFees < ActiveRecord::Migration[5.2]
  def change
    create_table :rates_fees, id: :uuid do |t|
      t.references :cargo, foreign_key: { to_table: :rates_cargos }, type: :uuid, index: true
      t.monetize :amount, amount: { limit: 8 }, currency: { default: nil }
      t.integer :rate_basis, default: 0, null: false
      t.numrange :kg_range
      t.numrange :stowage_range
      t.numrange :km_range
      t.numrange :cbm_range
      t.numrange :wm_range
      t.numrange :unit_range
      t.monetize :min_amount, amount: { limit: 8 }, currency: { default: nil }
      t.monetize :max_amount, amount: { limit: 8 }, currency: { default: nil }
      t.decimal :cbm_ratio, default: 1000
      t.integer :operator, default: 0, null: false
      t.integer :level, default: 0, null: false
      t.jsonb :rule
      t.daterange :validity

      t.timestamps
    end
  end
end
