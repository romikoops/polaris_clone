# frozen_string_literal: true

class AddTruckingTenantVehiclesToTenders < ActiveRecord::Migration[5.2]
  def change
    add_reference :quotations_tenders, :pickup_tenant_vehicle,
      foreign_key: {to_table: :tenant_vehicles},
      type: :integer, index: false
    add_reference :quotations_tenders, :delivery_tenant_vehicle,
      foreign_key: {to_table: :tenant_vehicles},
      type: :integer, index: false
  end
end
