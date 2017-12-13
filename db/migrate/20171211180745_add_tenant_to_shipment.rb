class AddTenantToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :tenant_id, :integer
  end
end
