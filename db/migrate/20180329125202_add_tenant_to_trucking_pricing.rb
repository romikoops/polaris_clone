class AddTenantToTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_pricings, :tenant_id, :integer
  end
end
