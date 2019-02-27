# frozen_string_literal: true

class AddCarrierIdToTenantVehicles < ActiveRecord::Migration[5.1]
  def change
    add_column :tenant_vehicles, :carrier_id, :integer
  end
end
