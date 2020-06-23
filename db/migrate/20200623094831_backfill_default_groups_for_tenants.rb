# frozen_string_literal: true

class BackfillDefaultGroupsForTenants < ActiveRecord::Migration[5.2]
  def change
    exec_update <<-SQL
       INSERT INTO tenants_groups(name, tenant_id, created_at, updated_at)
      SELECT
        'default',
        tenants_tenants.id,
        now(),
        now()
      FROM tenants_tenants
      LEFT JOIN tenants_groups ON tenants_groups.tenant_id = tenants_tenants.id AND tenants_groups.name = 'default'
      GROUP BY tenants_tenants.id
      HAVING count(tenants_groups.id) = 0
    SQL
  end
end
