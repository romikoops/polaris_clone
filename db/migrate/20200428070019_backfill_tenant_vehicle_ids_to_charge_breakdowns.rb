# frozen_string_literal: true

class BackfillTenantVehicleIdsToChargeBreakdowns < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<-SQL
        UPDATE charge_breakdowns
          SET freight_tenant_vehicle_id = trips.tenant_vehicle_id
        FROM trips
        WHERE charge_breakdowns.trip_id = trips.id
      SQL
    end
  end

  def down
  end
end
