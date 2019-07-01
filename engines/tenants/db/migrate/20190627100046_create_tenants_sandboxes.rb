class CreateTenantsSandboxes < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants_sandboxes, id: :uuid do |t|
      t.uuid :tenant_id
      t.string :name
      t.timestamps
    end
  end
end
