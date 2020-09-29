# frozen_string_literal: true

class Carrier < Legacy::Carrier
  has_many :tenant_vehicles

  def get_tenant_vehicle(organization_id, mode_of_transport, name)
    tv = tenant_vehicles.find_by(
      organization_id: organization_id,
      mode_of_transport: mode_of_transport,
      name: name
    )
    tv ||= Vehicle.create_from_name(name: name, mot: mode_of_transport, organization_id: organization_id, carrier: self.name)

    tv
  end
end

# == Schema Information
#
# Table name: carriers
#
#  id         :bigint           not null, primary key
#  code       :string
#  deleted_at :datetime
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
# Indexes
#
#  index_carriers_on_code        (code) UNIQUE WHERE (deleted_at IS NULL)
#  index_carriers_on_sandbox_id  (sandbox_id)
#
