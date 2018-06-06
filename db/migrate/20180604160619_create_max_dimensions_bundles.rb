class CreateMaxDimensionsBundles < ActiveRecord::Migration[5.1]
  def change
    create_table :max_dimensions_bundles do |t|
      t.string :mode_of_transport
      t.integer :tenant_id
      t.boolean :aggregate
      t.decimal :dimension_x
      t.decimal :dimension_y
      t.decimal :dimension_z
      t.decimal :payload_in_kg
      t.decimal :chargeable_weight

      t.timestamps
    end
  end
end
