class AddWebToTenants < ActiveRecord::Migration[5.1]
  def change
    add_column :tenants, :web, :jsonb
  end
end
