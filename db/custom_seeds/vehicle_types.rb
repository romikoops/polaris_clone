Tenant.all.each do |tenant|
  # Create vehicle types
  vehicle_types = [
    'ocean_default',
    'rail_default',
    'air_default',
    'truck_default'
  ]
  cargo_types = [
    'dry_goods',
    'liquid_bulk',
    'gas_bulk',
    'any'
  ]
  load_types = [
    'fcl_20f',
    'fcl_40f',
    'fcl_40f_hq',
    'lcl'
  ]

  vehicle_types.each do |vt|
    mot = vt.split('_')[0]
    vehicle = Vehicle.create(name: vt, mode_of_transport: mot)
    tenant.tenant_vehicles.create(name: vt, mode_of_transport: mot, vehicle_id: vehicle.id)

    load_types.each do |lt|
      cargo_types.each do |ct|
        vehicle.transport_categories.create(mode_of_transport: mot, cargo_class: lt, name: ct )
      end
    end
  end
end
