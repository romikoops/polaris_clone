# frozen_string_literal: true

class CreateRatesSections < ActiveRecord::Migration[5.2]
  def change
    create_table :rates_sections, id: :uuid do |t|
      t.references :target, polymorphic: true, type: :uuid
      t.references :tenant, foreign_key: {to_table: :tenants_tenants}, type: :uuid, index: true
      t.references :location, foreign_key: {to_table: :routing_locations}, type: :uuid, index: true
      t.references :terminal, foreign_key: {to_table: :routing_terminals}, type: :uuid, index: true
      t.references :carrier, foreign_key: {to_table: :carriers}, index: true
      t.integer :mode_of_transport
      t.integer :ldm_threshold_applicable
      t.integer :ldm_measurement
      t.decimal :ldm_ratio, default: 0
      t.decimal :ldm_threshold, default: 0.0
      t.boolean :disabled
      t.decimal :ldm_area_divisor
      t.decimal :truck_height
      t.timestamps
    end
  end
end
