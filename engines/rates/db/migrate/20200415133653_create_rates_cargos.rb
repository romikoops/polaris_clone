# frozen_string_literal: true

class CreateRatesCargos < ActiveRecord::Migration[5.2]
  def change
    create_table :rates_cargos, id: :uuid do |t|
      t.references :section, foreign_key: {to_table: :rates_sections}, type: :uuid, index: true
      t.integer :cargo_class, default: 0, index: true
      t.integer :cargo_type, default: 0, index: true
      t.integer :category, default: 0, index: true
      t.string :code
      t.integer :valid_at
      t.integer :operator
      t.integer :applicable_to, default: 0
      t.decimal :cbm_ratio
      t.integer :order, default: 0
      t.timestamps
    end
  end
end
