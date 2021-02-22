# frozen_string_literal: true
class CreateRatesMargins < ActiveRecord::Migration[5.2]
  def change
    create_table :rates_margins, id: :uuid do |t|
      t.references :organization, foreign_key: {to_table: :organizations_organizations}, type: :uuid, index: true
      t.references :target, polymorphic: true, type: :uuid
      t.integer :cargo_class, default: 0, index: true
      t.integer :cargo_type, default: 0, index: true
      t.references :applicable_to, polymorphic: true, type: :uuid
      t.integer :operator
      t.monetize :amount, amount: {limit: 8}, currency: {default: nil}
      t.decimal :percentage
      t.integer :rate_basis, default: 0, null: false
      t.numrange :kg_range
      t.numrange :stowage_range
      t.numrange :km_range
      t.numrange :cbm_range
      t.numrange :wm_range
      t.numrange :unit_range
      t.monetize :min_amount, amount: {limit: 8}, currency: {default: nil}
      t.monetize :max_amount, amount: {limit: 8}, currency: {default: nil}
      t.decimal :cbm_ratio, default: 1000
      t.daterange :validity
      t.integer :order, default: 0

      t.timestamps
    end
  end
end
