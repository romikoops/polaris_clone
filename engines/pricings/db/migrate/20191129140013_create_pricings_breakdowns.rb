# frozen_string_literal: true

class CreatePricingsBreakdowns < ActiveRecord::Migration[5.2]
  def change
    create_table :pricings_breakdowns, id: :uuid do |t|
      t.uuid :metadatum_id, null: false
      t.string :pricing_id
      t.string :cargo_class
      t.uuid :margin_id
      t.jsonb :data
      t.references :target, polymorphic: true, index: true, type: :uuid
      t.references :cargo_unit, polymorphic: true, index: true
      t.integer :charge_category_id
      t.integer :charge_id
      t.jsonb :rate_origin, default: {}
      t.integer :order
      t.timestamps
    end
  end
end
