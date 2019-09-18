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
#  id                :bigint(8)        not null, primary key
#  vehicle_id        :integer
#  tenant_id         :integer
#  is_default        :boolean
#  mode_of_transport :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string
#  carrier_id        :integer
#  sandbox_id        :uuid
#
