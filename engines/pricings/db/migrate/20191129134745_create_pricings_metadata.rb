# frozen_string_literal: true

class CreatePricingsMetadata < ActiveRecord::Migration[5.2]
  def change
    create_table :pricings_metadata, id: :uuid do |t|
      t.uuid :pricing_id
      t.integer :charge_breakdown_id
      t.integer :cargo_unit_id
      t.uuid :tenant_id
      t.timestamps
    end
  end
end
