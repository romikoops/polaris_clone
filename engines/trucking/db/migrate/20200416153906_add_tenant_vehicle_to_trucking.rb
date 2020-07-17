# frozen_string_literal: true

class AddTenantVehicleToTrucking < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_truckings, :tenant_vehicle_id, :integer
  end
end
