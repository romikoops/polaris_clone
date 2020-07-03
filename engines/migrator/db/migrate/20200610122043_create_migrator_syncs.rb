class CreateMigratorSyncs < ActiveRecord::Migration[5.2]
  def change
    create_table :migrator_syncs, id: false do |t|
      t.references :users_user, type: :uuid, index: true, foreign_key: true
      t.uuid :tenants_user_id, index: true
      t.integer :user_id, index: true

      t.index %i[users_user_id user_id], unique: true

      t.references :organizations_organization, type: :uuid, index: true, foreign_key: true
      t.uuid :tenants_tenant_id, index: true
      t.integer :tenant_id, index: true

      t.index %i[organizations_organization_id tenant_id], name: :index_migrator_syncs_on_organization_id_and_tenant_id,
                                                           unique: true
    end
  end
end
