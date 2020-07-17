# frozen_string_literal: true

class AddTenantVehicleIdsToChargeBreakdowns < ActiveRecord::Migration[5.2]
  def change
    add_reference :charge_breakdowns, :freight_tenant_vehicle,
      foreign_key: {to_table: :tenant_vehicles},
      type: :integer, index: false
    add_reference :charge_breakdowns, :pickup_tenant_vehicle,
      foreign_key: {to_table: :tenant_vehicles},
      type: :integer, index: false
    add_reference :charge_breakdowns, :delivery_tenant_vehicle,
      foreign_key: {to_table: :tenant_vehicles},
      type: :integer, index: false
  end
end
