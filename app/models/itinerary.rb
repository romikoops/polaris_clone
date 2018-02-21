class Itinerary < ApplicationRecord
  has_many :stops
  has_many :layovers
  has_many :shipments
  has_many :trips
  belongs_to :mot_scope, optional: true
  extend ItineraryTools
  include ItineraryTools
  def self.find_or_create_by_hubs(hub_ids, tenant_id, mot, vehicle_id, name)
    tenant = Tenant.find(tenant_id)
    stops = tenant.stops
      .where(hub_id: hub_ids)
      .group("stops.id, stops.itinerary_id")
    stops = stops.first.is_a?(Array) ? stops : [stops]    
    itineraries = stops.select {|itinerary_group| itinerary_group.size == hub_ids.size}
      .map { |itinerary_group| itinerary_group[0].itinerary }
      .select {|itinerary| itinerary.mode_of_transport == mot && vehicle_id == vehicle_id}
    if itineraries.empty?
      # create
      itinerary = tenant.itineraries.create!(mode_of_transport: mot, vehicle_id: vehicle_id, name: name)
    else
      itinerary = itineraries.first
    end
    return itinerary
  end

  def generate_schedules_from_sheet(stops, start_date, end_date, vehicle_id) 
   trip = self.trips.create!(start_date: start_date, end_date: end_date, vehicle_id: vehicle_id)
        stops.each do |stop|
          if stop.index == 0
            data = {
              eta: nil,
              etd: start_date,
              stop_index: stop.index,
              itinerary_id: stop.itinerary_id,
              stop_id: stop.id
            }
          else 
            data = {
              eta: end_date,
              etd: nil,
              stop_index: stop.index,
              itinerary_id: stop.itinerary_id,
              stop_id: stop.id
            }
          end
          trip.layovers.create!(data)
        end
  end

  def generate_weekly_schedules(stops_in_order, steps_in_order, start_date, end_date, ordinal_array, vehicle_id)
    if start_date.kind_of? Date
      tmp_date = start_date
    else
      tmp_date = DateTime.parse(start_date)
    end
    if end_date.kind_of? Date
      end_date_parsed = end_date
    else
      end_date_parsed = DateTime.parse(end_date)
    end
    steps_in_order = steps_in_order.map { |e| e.to_i }
    while tmp_date < end_date_parsed
      if ordinal_array.include?(tmp_date.strftime("%u").to_i)
        journey_start = tmp_date.midday
        journey_end = journey_start + steps_in_order.sum.days
        trip = self.trips.create!(start_date: journey_start, end_date: journey_end, vehicle_id: vehicle_id)
        p trip
        stops_in_order.each do |stop|
          if stop.index == 0
            data = {
              eta: nil,
              etd: journey_start,
              stop_index: stop.index,
              itinerary_id: stop.itinerary_id,
              stop_id: stop.id
            }
          else 
            journey_start += steps_in_order[stop.index - 1].days
            data = {
              eta: journey_start,
              etd: journey_start + 1.day,
              stop_index: stop.index,
              itinerary_id: stop.itinerary_id,
              stop_id: stop.id
            }
          end
          layover = trip.layovers.create!(data)
          p layover
        end
      end
      tmp_date += 1.day
    end
  end

  def prep_schedules(limit)
    schedules = []
    trip_layovers = self.trips.map { |t| t.layovers  }
    if limit
      trip_layovers = trip_layovers[0...limit]
    end
    trip_layovers.each do |l_arr|
      if l_arr.length > 1
        layovers_combinations = l_arr.map.with_index { |l, i| 
          if l_arr[i + 1]
            return [l, l_arr[i + 1]]
          end  
        }
        layovers_combinations.each do |lc|
          schedules.push({
            itinerary_id: self.id,
            eta: lc[1].eta, 
            etd: lc[0].etd, 
            mode_of_transport: lc[0].itinerary.mode_of_transport, 
            hub_route_key: "#{lc[0].stop.hub_id}-#{lc[1].stop.hub_id}", 
            tenant_id: self.tenant_id, 
            trip_id: lc[0].trip_id, 
            origin_layover_id: lc[0].id,
            destination_layover_id: lc[1].id
            })
        end
      end
    end
    
    schedules
  end

  def self.ids_dedicated(user = nil)
    get_itineraries_with_dedicated_pricings(user.id, user.tenant_id)
  end

  def modes_of_transport
    exists = -> mot { Itinerary.where(mode_of_transport: mot).limit(1).size > 0 }
    {
      ocean: exists.('ocean'),
      air:   exists.('air'),
      rails: exists.('rails')
    }
  end
  def hubs
    self.stops.flat_map { |s| s.hub }
  end
  def first_stop
    self.stops.order(index: :asc).first
  end

  def last_stop
    self.stops.order(index: :desc).first
  end

  def first_nexus
    self.stops.find_by(index: 0).hub.nexus
  end

  def last_nexus
    self.stops.order(index: :desc)[0].hub.nexus
  end

  def self.mot_scoped(tenant_id, mot_scope_ids)
    get_scoped_itineraries(tenant_id, mot_scope_ids)
  end

  def routes
    stops = self.stops.order(:index).to_a.combination(2).to_a
    return stops.map { |s| self.detailed_hash(
        s,
        {
          nexus_names: true,
          nexus_ids: true, 
          stop_ids: true,
          hub_ids: true,
          hub_names: true,
          modes_of_transport: true
        }
      ) }
  end
  def detailed_hash(stop_array, options = {})
    origin = stop_array[0]
    destination = stop_array[1]
    return_h = attributes
    return_h[:origin_nexus]       = origin.hub.nexus.name                if options[:nexus_names] 
    return_h[:destination_nexus]  = destination.hub.nexus.name           if options[:nexus_names]
    return_h[:origin_nexus_id]       = origin.hub.nexus.id               if options[:nexus_ids] 
    return_h[:destination_nexus_id]  = destination.hub.nexus.id          if options[:nexus_ids]
    return_h[:origin_hub_id]       = origin.hub.id                       if options[:hub_ids] 
    return_h[:destination_hub_id]  = destination.hub.id                  if options[:hub_ids]
    return_h[:origin_hub_name]       = origin.hub.name                   if options[:hub_names] 
    return_h[:destination_hub_name]  = destination.hub.name              if options[:hub_names]
    return_h[:origin_stop_id]       = origin.id                          if options[:stop_ids] 
    return_h[:destination_stop_id]  = destination.id                     if options[:stop_ids]
    return_h[:modes_of_transport] = modes_of_transport                   if options[:modes_of_transport]
    return_h[:next_departure]     = next_departure                       if options[:next_departure]
    return_h[:dedicated]          = options[:ids_dedicated].include?(id) unless options[:ids_dedicated].nil?
    return_h
  end

  def load_types
    load_types = TransportCategory::LOAD_TYPES.reject do |load_type|
      get_itinerary_pricings(id, TransportCategory.load_type(load_type).ids).empty?
    end
  end

  def self.for_locations(shipment, radius = 200)
    start_city, start_city_dist = shipment.origin.closest_location_with_distance

    end_city, end_city_dist = shipment.destination.closest_location_with_distance
    if start_city_dist > radius || end_city_dist > radius
      start_city = end_city = nil
    end
    start_hubs = start_city.hubs.where(tenant_id: shipment.tenant_id)
    end_hubs = end_city.hubs.where(tenant_id: shipment.tenant_id)
    start_hub_ids = start_hubs.ids
    end_hub_ids = end_hubs.ids
    query = "SELECT *
      FROM itineraries
      WHERE tenant_id = #{shipment.tenant_id} AND id IN (
        SELECT d_stops.itinerary_id
        FROM (
          SELECT id, itinerary_id, index
          FROM stops
          WHERE hub_id IN #{start_hub_ids.sql_format}
        ) as o_stops
        JOIN (
          SELECT id, itinerary_id, index
          FROM stops
          WHERE hub_id IN #{end_hub_ids.sql_format}
        ) as d_stops
        ON o_stops.itinerary_id = d_stops.itinerary_id
        WHERE o_stops.index < d_stops.index
      )"
    results = Itinerary.find_by_sql(query)
    return {itineraries: results, origin_hubs: start_hubs, destination_hubs: end_hubs}
  end

  def set_scope!
    scope_attributes_arr = modes_of_transport.select { |k, v| v }.keys.map do |mode_of_transport|
      load_types.map { |load_type| "#{mode_of_transport}_#{load_type}" }
    end.flatten
    scope_attributes = MotScope.given_attribute_names.each_with_object({}) do |attribute_name, h|
      h[attribute_name] = scope_attributes_arr.include?(attribute_name)
    end
    self.mot_scope = MotScope.find_by(scope_attributes)
    save!
  end

  def self.update_hubs
    its = Itinerary.all
    its.each do |it|
      hub_arr = []
      hubs = it.stops.order(:index).each do |s|
        hub_arr << {hub_id: s.hub_id, index: s.index}
      end
      it.hubs = hub_arr
      it.save!
    end
  end
end
