class CreateTenantsGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants_groups, id: :uuid do |t|
      t.string :name
      t.uuid :tenant_id
      t.timestamps
    end
  end
end
