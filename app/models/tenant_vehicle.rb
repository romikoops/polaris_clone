class TenantVehicle < ApplicationRecord
  belongs_to :tenant
  belongs_to :vehicle
  after_create do |tvt|
    vt = tvt.vehicle
    tvt.mode_of_transport = vt.mode_of_transport
    default_tvt = TenantVehicle.find_by(mode_of_transport: tvt.mode_of_transport, is_default: true)
    if !default_tvt
      tvt.is_default = true
    end
    tvt.save!
  end
end
