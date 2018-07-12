module SetupHelper

  def variables_setup(args = {})
    _user = user
    _transport_category = transport_category(cargo_class: args[:cargo_class], load_type: args[:load_type])
    _vehicle = vehicle(categories: [_transport_category], name: args[:vehicle_name])
    _tenant_vehicle = tenant_vehicle(name: args[:tenant_vehicle_name], vehicle: _vehicle)
    _itinerary = itinerary(mot: args[:mode_of_transport])
    _trip = trip(tenant_vehicle: _tenant_vehicle, itinerary: _itinerary)
    _pricing = pricing(user: _user, transport_category: _transport_category, trip: _trip)
    
    _cargo_item = cargo_item(quantity: args[:quantity], dimension_x: args[:dimension_x],
      dimension_y: args[:dimension_y], dimension_z: args[:dimension_z],
      payload_in_kg: args[:payload_in_kg], cargo_class: args[:cargo_class])

    _container = container(quantity: args[:quantity], payload_in_kg: args[:payload_in_kg],
      cargo_class: args[:cargo_class], size_class: args[:size_class], weight_class: args[:weight_class])

    _origin_nexus = origin_nexus(name: args[:origin_nexus_name])
    _origin_hub  = origin_hub(port: args[:origin_port], origin_nexus: _origin_nexus)
    _destination_nexus = destination_nexus(name: args[:destination_nexus_name])
    _destination_hub = destination_hub(port: args[:destination_port], destination_nexus: _destination_nexus)

    _shipment = shipment(cargo_items: [_cargo_item], user: _user, shipment_status: args[:shipment_status],
      trip: _trip, load_type: args[:load_type], direction: args[:direction], origin_hub: _origin_hub,
      origin_nexus: _origin_nexus, destination_hub: _destination_hub, destination_nexus:  _destination_nexus,
      trucking: args[:trucking], eta: args[:eta], etd: args[:etd], closing_date: args[:closing_date])
    _schedule = schedule(_shipment)

    {
      _user: _user,
      _transport_category: _transport_category,
      _vehicle: _vehicle,
      _tenant_vehicle: _tenant_vehicle,
      _trip: _trip,
      _pricing: _pricing,
      _cargo_item: _cargo_item,
      _container: _container,
      _origin_nexus: _origin_nexus,
      _origin_hub: _origin_hub,
      _destination_nexus: _destination_nexus,
      _destination_hub: _destination_hub,
      _itinerary: _itinerary,
      _shipment: _shipment,
      _schedule: _schedule
    }
  end

  def user
    create(:user)
  end

  def transport_category(arg = {})
    create(:transport_category, cargo_class: arg[:cargo_class] || 'lcl',
      load_type: arg[:load_type] || 'cargo_item')
  end

  def vehicle(arg)
    create(:vehicle, name: arg[:name] || 'express', transport_categories: arg[:categories])
  end
  
  def tenant_vehicle(arg)
    create(:tenant_vehicle, name: arg[:name] || 'express', vehicle: arg[:vehicle])
  end

  def itinerary(arg = {})
    create(:itinerary, mode_of_transport:  arg[:mot] || 'ocean')
  end

  def trip(arg)
    create(:trip,
      layovers: [create(:layover), create(:layover)],
      tenant_vehicle: arg[:tenant_vehicle], itinerary: arg[:itinerary])
  end

  def pricing(arg)
    create(:pricing, tenant: arg[:user].tenant,
    transport_category: arg[:transport_category], itinerary: arg[:trip].itinerary)
  end

  def cargo_item(arg = {})
    create(:cargo_item, quantity: arg[:quantity] || 1, dimension_x: arg[:dimension_x] || 20,
      dimension_y: arg[:dimension_y] || 20, dimension_z: arg[:dimension_z] || 20,
      payload_in_kg: arg[:payload_in_kg] || 200, cargo_class: arg[:cargo_class] || 'lcl')
  end

  def container(arg = {})
    create(:container, quantity: arg[:quantity] || 1, payload_in_kg: arg[:payload_in_kg] || 10000,
      cargo_class: arg[:cargo_class] || 'fcl_20', size_class: arg[:size_class] || 'fcl_20',
      weight_class: arg[:weight_class] || '14t')
  end

  def origin_nexus(arg)
    create(:nexus, name: arg[:name] || "Shanghai")
  end

  def origin_hub(arg)
    create(:hub, name: arg[:port] || "Shanghai Port", nexus: arg[:origin_nexus])
  end

  def destination_nexus(arg)
    create(:nexus, name: arg[:name] || "Gothenburg")
  end

  def destination_hub(arg)
    create(:hub, name: arg[:port] || "Gothenburg port", nexus: arg[:destination_nexus])
  end

  def shipment(arg)
    create(:shipment,
      user: arg[:user], status: arg[:shipment_status] || 'requested', trip: arg[:trip],
      load_type: arg[:load_type] || 'cargo_item', direction: arg[:direction] || 'export',
      total_goods_value: 1500, booking_placed_at: Time.now, origin_hub: arg[:origin_hub],
      origin_nexus: arg[:origin_nexus], destination_hub: arg[:destination_hub],
      destination_nexus: arg[:destination_nexus], cargo_items: arg[:cargo_items],
      trucking: arg[:trucking], planned_eta: arg[:eta], planned_etd: arg[:etd],
      closing_date: arg[:closing_date])
  end

  def schedule(shipment)
    Schedule.new(
      origin_hub_id:        shipment.origin_hub.id,
      destination_hub_id:   shipment.destination_hub.id,
      origin_hub_name:      shipment.origin_hub.name,
      destination_hub_name: shipment.destination_hub.name,
      mode_of_transport:    shipment.mode_of_transport,
      eta:                  shipment.planned_eta,
      etd:                  shipment.planned_etd,
      closing_date:         shipment.closing_date,
      trip_id:              shipment.trip_id
    )
  end

  def request_stubber(access_key, currency)
    Net::HTTP.get_response(URI("http://data.fixer.io/latest?access_key=#{access_key}&base=#{currency}"))
  end
end
