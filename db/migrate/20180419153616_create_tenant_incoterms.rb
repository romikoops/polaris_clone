class CreateTenantIncoterms < ActiveRecord::Migration[5.1]
  def change
    create_table :tenant_incoterms do |t|
      t.integer :tenant_id
      t.integer :incoterm_id
      t.timestamps
    end
  end
end
