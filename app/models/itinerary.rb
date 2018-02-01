class Itinerary < ApplicationRecord
  has_many :stops
  has_many :layovers
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

  def generate_weekly_schedules(stops_in_order, steps_in_order, start_date, end_date, ordinal_array)
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
    
    while tmp_date < end_date_parsed
      if ordinal_array.include?(tmp_date.strftime("%u").to_i)
        journey_start = tmp_date.midday
        stops_in_order.each do |stop|
          if stop.index == 0
            data = {
              eta: nil,
              etd: journey_start,
              stop_index: stop.index,
              itinerary_id: stop.itinerary_id
            }
          else 
            journey_start += steps_in_order[stop.index - 1]
            data = {
              eta: journey_start,
              etd: journey_start + 1.day,
              stop_index: stop.index,
              itinerary_id: stop.itinerary_id
            }
          end
          stop.layovers.create!(data)
        end
      end
      tmp_date += 1.day
    end
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
  def first_stop
    self.stops.find_by(index: 0).hub.nexus
  end

  def last_stop
    self.stops.order(index: :desc)[0].hub.nexus
  end
  def self.mot_scoped(tenant_id, mot_scope_ids)
    get_scoped_itineraries(tenant_id, mot_scope_ids)
  end

  def detailed_hash(options = {})
    return_h = attributes
    return_h[:origin_nexus]       = first_stop.name                      if options[:nexus_names] 
    return_h[:destination_nexus]  = last_stop.name                       if options[:nexus_names]
    return_h[:origin_nexus_id]       = first_stop.id                   if options[:nexus_ids] 
    return_h[:destination_nexus_id]  = last_stop.id                    if options[:nexus_ids]
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
    o_stops = start_city.stops.pluck(:id)
    d_stops = end_city.stops.pluck(:id)
    o_stops.each do |ost|
      d_stops.each do |dst|
        if dst.hub_id == ost.hub_id && dst.index < ost.index
          d_stops.delete(dst)
          o_stops.delete(ost)
        end
      end
    end
    o_results = Itinerary.joins(:stops).group("itineraries.id, stops.id").having("stops.id IN (?)", o_stops)
    d_results = Itinerary.joins(:stops).group("itineraries.id, stops.id").having("stops.id IN (?)", d_stops)
    results = o_results & d_results
    # o_layovers = Layover.where("etd > ?", shipment.planned_pickup_date + 3.days).where("etd < ?", shipment.planned_pickup_date + 15.days).where(stop_id: o_stops.pluck(:id)).where(itinerary_id: o_stops.pluck(:itinerary_id))
    byebug
    o_layovers.each do |lay|

    end
    
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
end
