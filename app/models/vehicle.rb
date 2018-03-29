class Vehicle < ApplicationRecord
  has_many :transport_categories
  has_many :itineraries

  validates :name,
  	presence: true,
  	uniqueness: {
  		scope: :mode_of_transport,
  		message: -> _self, _ do
  			"'#{_self.name}' taken for mode of transport '#{_self.mode_of_transport}'"
  		end
		}
		def self.create_from_name(name, mot, tenant_id)
			vehicle = Vehicle.find_or_create_by!(name: name, mode_of_transport: mot)
			tv = TenantVehicle.find_or_create_by(name: name, mode_of_transport: mot, vehicle_id: vehicle.id, tenant_id: tenant_id)
			return tv
		end
end
