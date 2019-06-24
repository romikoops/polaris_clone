# frozen_string_literal: true

class CreatePricingsPricings < ActiveRecord::Migration[5.2]
  def change
    create_table :pricings_pricings, id: :uuid do |t|
      t.decimal :wm_rate
      t.datetime :effective_date
      t.datetime :expiration_date
      t.bigint :tenant_id, index: true
      t.string :cargo_class, index: true
      t.string :load_type, index: true
      t.bigint :user_id, index: true
      t.bigint :itinerary_id, index: true
      t.integer :tenant_vehicle_id, index: true
      t.integer :legacy_id
      t.timestamps
    end
  end
end
