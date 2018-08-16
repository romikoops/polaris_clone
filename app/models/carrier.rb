class Carrier < ApplicationRecord
  has_many :tenant_vehicles

  def get_tenant_vehicle(tenant_id, mode_of_transport, name)
    tv = self.tenant_vehicles.find_by(
      tenant_id:         tenant_id,
      mode_of_transport: mode_of_transport,
      name:              name
    )
    if !tv
      tv = Vehicle.create_from_name(name, mode_of_transport, tenant_id, self.name)
    end
    
    return tv
  end
end
