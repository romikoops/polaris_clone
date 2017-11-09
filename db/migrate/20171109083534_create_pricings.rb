class CreatePricings < ActiveRecord::Migration[5.1]
  def change
    create_table :pricings do |t|
      t.integer :tenant_id
      t.integer :route_id
      t.integer :customer_id

      t.jsonb :air, default: {
        currency: nil,
        kg_per_cbm: 167,
        wm_rate: nil,
        wm_min: 1,
        heavy_weight: nil,
        heavy_wm_min: 1
      }

      t.jsonb :lcl, default: {
        currency: nil,
        kg_per_cbm: 1000,
        wm_rate: nil,
        wm_min: 1,
        heavy_weight: nil,
        heavy_wm_min: 1
      }

      t.jsonb :fcl_20f, default: {
        currency: nil,
        kg_per_cbm: 1000,
        rate: nil,
        heavy_weight: nil,
        heavy_kg_min: nil
      }

      t.jsonb :fcl_40f, default: {
        currency: nil,
        kg_per_cbm: 1000,
        rate: nil,
        heavy_weight: nil,
        heavy_kg_min: nil
      }

      t.jsonb :fcl_40f_hq, default: {
        currency: nil,
        kg_per_cbm: 1000,
        rate: nil,
        heavy_weight: nil,
        heavy_kg_min: nil
      }
      t.timestamps
    end
  end
end
