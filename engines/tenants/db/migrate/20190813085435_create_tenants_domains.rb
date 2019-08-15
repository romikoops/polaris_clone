class CreateTenantsDomains < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants_domains, id: :uuid do |t|
      t.uuid :tenant_id
      t.string :domain
      t.boolean :default

      t.timestamps
    end
  end
end
