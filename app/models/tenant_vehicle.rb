# frozen_string_literal: true

class TenantVehicle < Legacy::TenantVehicle
  belongs_to :tenant
  belongs_to :vehicle
  belongs_to :carrier, optional: true
  has_many :pricings
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  after_create do |tvt|
    vt = tvt.vehicle
    tvt.mode_of_transport = vt.mode_of_transport
    default_tvt = TenantVehicle.find_by(
      mode_of_transport: tvt.mode_of_transport,
      is_default: true,
      tenant_id: tvt.tenant_id
    )
    tvt.is_default = true unless default_tvt
    tvt.save!
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
