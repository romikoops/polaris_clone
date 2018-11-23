class AddTenantIdToChargeCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :charge_categories, :tenant_id, :integer
  end
end
