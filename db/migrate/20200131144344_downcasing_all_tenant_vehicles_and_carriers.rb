# frozen_string_literal: true

class DowncasingAllTenantVehiclesAndCarriers < ActiveRecord::Migration[5.2]
  def change
    TenantVehicle.find_each do |tenant_vehicle|
      tenant_vehicle.update(name: tenant_vehicle.name.downcase.strip)
    end
    Carrier.find_each do |carrier|
      carrier.update(name: carrier.name&.downcase&.strip)
    end
  end
end
