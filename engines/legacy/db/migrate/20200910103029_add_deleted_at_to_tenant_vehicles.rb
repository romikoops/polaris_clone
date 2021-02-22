# frozen_string_literal: true
class AddDeletedAtToTenantVehicles < ActiveRecord::Migration[5.2]
  def change
    add_column :tenant_vehicles, :deleted_at, :datetime
  end
end
