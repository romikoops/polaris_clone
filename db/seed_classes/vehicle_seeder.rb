class VehicleSeeder
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

  def self.exec(filter = {})
		Tenant.where(filter).each do |tenant|
		  VEHICLE_NAMES.each do |vehicle_name|
		    mot = vehicle_name.split('_')[0]
		    vehicle = Vehicle.find_or_create_by(name: vehicle_name, mode_of_transport: mot)
		    tenant.tenant_vehicles.find_or_create_by(
		      name: vehicle_name, mode_of_transport: mot, vehicle_id: vehicle.id
		    )

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
		end
	end
end