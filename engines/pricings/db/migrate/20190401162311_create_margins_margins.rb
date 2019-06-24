# frozen_string_literal: true

class CreateMarginsMargins < ActiveRecord::Migration[5.2]
  def change
    create_table :pricings_margins, id: :uuid do |t|
      t.uuid :tenant_id, index: true
      t.uuid :pricing_id, index: true
      t.string :default_for
      t.string :operator
      t.decimal :value
      t.datetime :effective_date, index: true
      t.datetime :expiration_date, index: true
      t.references :applicable, polymorphic: true, index: true, type: :uuid
      t.integer :tenant_vehicle_id, index: true
      t.string :cargo_class, index: true
      t.integer :itinerary_id, index: true
      t.integer :origin_hub_id, index: true
      t.integer :destination_hub_id, index: true
      t.integer :application_order, index: true, default: 0
      t.timestamps
    end
  end
end
