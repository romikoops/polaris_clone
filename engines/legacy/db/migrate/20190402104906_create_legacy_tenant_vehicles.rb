# frozen_string_literal: true

class CreateLegacyTenantVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_tenant_vehicles, id: :uuid, &:timestamps
  end
end
