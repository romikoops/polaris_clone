# frozen_string_literal: true
class BackfillTenantVehiclesCarrierLock < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    exec_update <<-SQL
          UPDATE tenant_vehicles
          SET carrier_lock = FALSE
          WHERE carrier_lock IS NULL
    SQL
  end

  def down
  end
end
