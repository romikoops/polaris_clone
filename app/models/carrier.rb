# frozen_string_literal: true

class Carrier < Legacy::Carrier
  has_many :tenant_vehicles
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  def get_tenant_vehicle(tenant_id, mode_of_transport, name)
    tv = tenant_vehicles.find_by(
      tenant_id: tenant_id,
      mode_of_transport: mode_of_transport,
      name: name
    )
    tv ||= Vehicle.create_from_name(name: name, mot: mode_of_transport, tenant_id: tenant_id, carrier: self.name)

    tv
  end
end

# == Schema Information
#
# Table name: carriers
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
