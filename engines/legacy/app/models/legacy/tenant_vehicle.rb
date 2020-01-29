# frozen_string_literal: true

module Legacy
  class TenantVehicle < ApplicationRecord
    self.table_name = 'tenant_vehicles'
    belongs_to :tenant
    belongs_to :vehicle
    belongs_to :carrier, optional: true
    has_many :pricings, class_name: 'Legacy::Pricing'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    def full_name
      carrier_id ? "#{carrier&.name} - #{name}" : name
    end
  end
end

# == Schema Information
#
# Table name: tenant_vehicles
#
#  id                :bigint           not null, primary key
#  is_default        :boolean
#  mode_of_transport :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  carrier_id        :integer
#  sandbox_id        :uuid
#  tenant_id         :integer
#  vehicle_id        :integer
#
# Indexes
#
#  index_tenant_vehicles_on_sandbox_id  (sandbox_id)
#  index_tenant_vehicles_on_tenant_id   (tenant_id)
#
