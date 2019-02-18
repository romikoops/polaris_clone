class CreateTruckingRates < ActiveRecord::Migration[5.2]
  def change
    create_table :trucking_rates, id: :uuid do |t|
      t.jsonb :load_meterage
      t.integer :cbm_ratio
      t.string :modifier
      t.integer :tenant_id
      t.datetime :created_at
      t.datetime :updated_at
      t.jsonb :rates
      t.jsonb :fees
      t.string :identifier_modifier
      t.uuid :scope_id
      t.index ["scope_id"], name: "index_trucking_rates_on_trucking_scope_id"
      t.timestamps
    end
  end
end
