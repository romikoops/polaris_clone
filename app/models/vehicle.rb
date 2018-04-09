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
		VEHICLE_NAMES = [
    'ocean_default',
    'rail_default',
    'air_default',
    'truck_default'
  ]
  TRANSPORT_CATEGORY_NAMES = [
    'dry_goods',
    'liquid_bulk',
    'gas_bulk',
    'any'
  ]
  CARGO_CLASSES = [
    'fcl_20f',
    'fcl_40f',
    'fcl_40f_hq',
    'lcl'
  ]
		def self.create_from_name(name, mot, tenant_id)
			vehicle = Vehicle.find_or_create_by!(name: name, mode_of_transport: mot)
			tv = TenantVehicle.find_or_create_by(name: name, mode_of_transport: mot, vehicle_id: vehicle.id, tenant_id: tenant_id)
			if vehicle.transport_categories.length < 1
				CARGO_CLASSES.each do |cargo_class|
		      TRANSPORT_CATEGORY_NAMES.each do |transport_category_name|
		        transport_category = TransportCategory.new(
		          name: transport_category_name,
		          mode_of_transport: mot,
		          cargo_class: cargo_class,
		          vehicle: vehicle
		        )
		        puts transport_category.errors.full_messages unless transport_category.save
		      end
		    end
			end
			return tv
		end
		def create_all_transport_categories
			CARGO_CLASSES.each do |cargo_class|
		      TRANSPORT_CATEGORY_NAMES.each do |transport_category_name|
		        transport_category = TransportCategory.new(
		          name: transport_category_name,
		          mode_of_transport: self.mode_of_transport,
		          cargo_class: cargo_class,
		          vehicle: self
		        )
		        puts transport_category.errors.full_messages unless transport_category.save
		      end
		    end
		end
end
