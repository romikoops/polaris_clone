class CreateTenantCargoItemTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :tenant_cargo_item_types do |t|
      t.references :tenant, foreign_key: true
      t.references :cargo_item_type, foreign_key: true

      t.timestamps
    end
  end
end
