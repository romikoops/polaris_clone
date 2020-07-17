# frozen_string_literal: true

class AddTenantVehicleIndexToTrucking < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :trucking_truckings, :tenant_vehicle_id, algorithm: :concurrently
  end
end
