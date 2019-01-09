# frozen_string_literal: true

class Carrier < ApplicationRecord
  has_many :tenant_vehicles

  def get_tenant_vehicle(tenant_id, mode_of_transport, name)
    tv = tenant_vehicles.find_by(
      tenant_id: tenant_id,
      mode_of_transport: mode_of_transport,
      name: name
    )
    tv ||= Vehicle.create_from_name(name, mode_of_transport, tenant_id, self.name)

    tv
  end
end

# == Schema Information
#
# Table name: carriers
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
