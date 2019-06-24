# frozen_string_literal: true

class CreatePricingsFees < ActiveRecord::Migration[5.2]
  def change
    create_table :pricings_fees, id: :uuid do |t|
      t.decimal :rate
      t.decimal :base
      t.uuid :rate_basis_id
      t.decimal :min
      t.decimal :hw_threshold
      t.uuid :hw_rate_basis_id
      t.integer :charge_category_id
      t.jsonb :range, default: []
      t.string :currency_name
      t.bigint :currency_id
      t.uuid :pricing_id
      t.bigint :tenant_id
      t.integer :legacy_id
      t.timestamps
    end
  end
end
