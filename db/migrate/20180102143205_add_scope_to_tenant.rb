class AddScopeToTenant < ActiveRecord::Migration[5.1]
  def change
    add_column :tenants, :scope, :jsonb
  end
end
