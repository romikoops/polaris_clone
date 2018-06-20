# frozen_string_literal: true

class Itinerary < ApplicationRecord
  extend ItineraryTools
  include ItineraryTools

  belongs_to :tenant
  has_many :stops,     dependent: :destroy
  has_many :layovers,  dependent: :destroy
  has_many :shipments, dependent: :destroy
  has_many :trips,     dependent: :destroy
  has_many :notes,     dependent: :destroy
  has_many :pricings,  dependent: :destroy
  has_many :hubs,      through: :stops

  scope :for_mot, ->(mot_scope_ids) { where(mot_scope_id: mot_scope_ids) }
  # scope :for_hub, ->(hub_ids) { where(hub_id: hub_ids) } # TODO: join stops

  validate :must_have_stops

  def generate_schedules_from_sheet(stops, start_date, end_date, tenant_vehicle_id, closing_date, vessel, voyage_code)
    results = {
      layovers: [],
      trips:    []
    }
    trip_check = trips.find_by(start_date: start_date, end_date: end_date, tenant_vehicle_id: tenant_vehicle_id, vessel: vessel, voyage_code: voyage_code)
    if trip_check
      p "REJECTED"
      # return results
    end
    trip = trips.create!(start_date: start_date, end_date: end_date, tenant_vehicle_id: tenant_vehicle_id, vessel: vessel, voyage_code: voyage_code)
    results[:trips] << trip
    stops.each do |stop|
      data =
        if stop.index.zero?
          {
            closing_date: closing_date,
            eta:          nil,
            etd:          start_date,
            stop_index:   stop.index,
            itinerary_id: stop.itinerary_id,
            stop_id:      stop.id
          }
        else
          {
            eta:          end_date,
            etd:          nil,
            stop_index:   stop.index,
            itinerary_id: stop.itinerary_id,
            stop_id:      stop.id
          }
        end
      layover = trip.layovers.find_or_create_by!(data)
      results[:layovers] << layover
    end
    results
  end

  def generate_weekly_schedules(stops_in_order, steps_in_order, start_date, end_date, ordinal_array, tenant_vehicle_id, closing_date_buffer=4)
    results = {
      layovers: [],
      trips:    []
    }
    stats = {
      layovers: {
        number_created: 0,
        number_updated: 0
      },
      trips:    {
        number_created: 0,
        number_updated: 0
      }
    }

    tmp_date = start_date.is_a?(Date)      ? start_date : DateTime.parse(start_date)
    end_date_parsed = end_date.is_a?(Date) ? end_date   : DateTime.parse(end_date)

    steps_in_order = steps_in_order.map(&:to_i)
    while tmp_date < end_date_parsed
      if ordinal_array.include?(tmp_date.strftime("%u").to_i)
        journey_start = tmp_date.midday
        closing_date = journey_start - closing_date_buffer.days
        journey_end = journey_start + steps_in_order.sum.days
        trip_check = trips.find_by(start_date: journey_start, end_date: journey_end, tenant_vehicle_id: tenant_vehicle_id, closing_date: closing_date)
        if trip_check && !trip_check.layovers.empty?
          tmp_date += 1.day
          stats[:trips][:number_updated] += 1
          next
        end
        trip = trips.create!(start_date: journey_start, end_date: journey_end, tenant_vehicle_id: tenant_vehicle_id, closing_date: closing_date)
        results[:trips] << trip
        stats[:trips][:number_created] += 1
        stops_in_order.each do |stop|
          if stop.index.zero?
            data = {
              eta:          nil,
              etd:          journey_start,
              stop_index:   stop.index,
              itinerary_id: stop.itinerary_id,
              stop_id:      stop.id,
              closing_date: closing_date
            }
          else
            journey_start += steps_in_order[stop.index - 1].days
            data = {
              eta:          journey_start,
              etd:          journey_start + 1.day,
              stop_index:   stop.index,
              itinerary_id: stop.itinerary_id,
              stop_id:      stop.id
            }
          end
          layover = trip.layovers.create!(data)
          results[:layovers] << layover
          stats[:layovers][:number_created] += 1
        end
      end
      p tmp_date
      tmp_date += 1.day
    end
    { results: results, stats: stats }
  end

  def prep_schedules(limit)
    schedules = []
    trip_layovers = trips.order(:start_date).map(&:layovers)
    trip_layovers = trip_layovers[0...limit] if limit
    trip_layovers.each do |l_arr|
      next unless l_arr.length > 1
      layovers_combinations = []
      l_arr.each_with_index do |l, i|
        layovers_combinations << [l, l_arr[i + 1]] if l_arr[i + 1]
      end
      layovers_combinations.each do |lc|
        schedules.push(
          itinerary_id:           id,
          eta:                    lc[1].eta,
          etd:                    lc[0].etd,
          mode_of_transport:      lc[0].itinerary.mode_of_transport,
          hub_route_key:          "#{lc[0].stop.hub_id}-#{lc[1].stop.hub_id}",
          tenant_id:              tenant_id,
          trip_id:                lc[0].trip_id,
          origin_layover_id:      lc[0].id,
          destination_layover_id: lc[1].id,
          closing_date:           lc[0].closing_date
        )
      end
    end

    schedules
  end

  def self.ids_dedicated(user=nil)
    get_itineraries_with_dedicated_pricings(user.id, user.tenant_id)
  end

  def modes_of_transport
    exists = ->(mot) { !Itinerary.where(mode_of_transport: mot).limit(1).empty? }
    {
      ocean: exists.call("ocean"),
      air:   exists.call("air"),
      rail:  exists.call("rail"),
      truck: exists.call("truck")
    }
  end

  def first_stop
    stops.order(index: :asc).limit(1).first
  end

  def last_stop
    stops.order(index: :desc).limit(1).first
  end

  def origin_stops
    stops.where.not(id: last_stop.id).order(index: :asc)
  end

  def destination_stops
    stops.where.not(id: first_stop.id).order(index: :desc)
  end

  def first_nexus
    first_stop.hub.nexus
  end

  def last_nexus
    last_stop.hub.nexus
  end

  def nexus_ids_for_target(target)
    try("#{target}_nexus_ids".to_sym)
  end

  def origin_nexus_ids
    origin_stops.joins(:hub).pluck("hubs.nexus_id")
  end

  def destination_nexus_ids
    destination_stops.joins(:hub).pluck("hubs.nexus_id")
  end

  def origin_nexuses
    Location.where(id: origin_nexus_ids)
  end

  def destination_nexuses
    Location.where(id: destination_nexus_ids)
  end

  def users_with_pricing
    pricings.where.not(user_id: nil).count
  end

  def pricing_count
    pricings.count
  end

  def routes
    stops.order(:index).to_a.combination(2).map do |stop_array|
      if !stop_array[0].hub || !stop_array[1].hub
        stop_array[0].itinerary.destroy
        return
      end
      {
        origin: stop_array[0].hub.lng_lat_array,
        destination: stop_array[1].hub.lng_lat_array,
        line: {
          type: 'LineString',
          id: "#{self.id}-#{stop_array[0].index}",
          coordinates: [stop_array[0].hub.lng_lat_array, stop_array[1].hub.lng_lat_array]
        }
      }
    end
  end


  def detailed_hash(stop_array, options={})
    origin = stop_array[0]
    destination = stop_array[1]
    return_h = attributes
    return_h[:origin_nexus]         = origin.hub.nexus.name                if options[:nexus_names]
    return_h[:destination_nexus]    = destination.hub.nexus.name           if options[:nexus_names]
    return_h[:origin_nexus_id]      = origin.hub.nexus.id                  if options[:nexus_ids]
    return_h[:destination_nexus_id] = destination.hub.nexus.id             if options[:nexus_ids]
    return_h[:origin_hub_id]        = origin.hub.id                        if options[:hub_ids]
    return_h[:destination_hub_id]   = destination.hub.id                   if options[:hub_ids]
    return_h[:origin_hub_name]      = origin.hub.name                      if options[:hub_names]
    return_h[:destination_hub_name] = destination.hub.name                 if options[:hub_names]
    return_h[:origin_stop_id]       = origin.id                            if options[:stop_ids]
    return_h[:destination_stop_id]  = destination.id                       if options[:stop_ids]
    return_h[:modes_of_transport]   = modes_of_transport                   if options[:modes_of_transport]
    return_h[:next_departure]       = next_departure                       if options[:next_departure]
    return_h[:dedicated]            = options[:ids_dedicated].include?(id) unless options[:ids_dedicated].nil?
    return_h
  end

  def load_types
    TransportCategory::LOAD_TYPES.reject do |load_type|
      pricings.where(transport_category_id: TransportCategory.load_type(load_type).ids).none?
    end
  end

  def ordered_nexus_ids
    stops.order(index: :asc).joins(:hub).pluck("hubs.nexus_id")
  end

  def has_route?(origin_nexus_id, destination_nexus_id)
    ordered_nexus_ids.include?(origin_nexus_id) &&
      ordered_nexus_ids.include?(destination_nexus_id) &&
      ordered_nexus_ids.index(origin_nexus_id) < ordered_nexus_ids.index(destination_nexus_id)
  end

  def available_counterpart_nexus_ids_for_target_nexus_ids(target, counterpart_nexus_ids)
    raise ArgumentError unless %w[origin destination].include?(target)

    counterpart_nexus_ids.map do |counterpart_nexus_id|
      next unless ordered_nexus_ids.include?(counterpart_nexus_id)

      counterpart_idx = ordered_nexus_ids.index(counterpart_nexus_id)

      target_range = target == "origin" ? 0...counterpart_idx : (counterpart_idx + 1)..-1
      ordered_nexus_ids[target_range]
    end.compact.flatten.uniq
  end

  def self.ids_with_route_stops_for(origin_hub_ids, destination_hub_ids)
    sanitized_query = sanitize_sql(["
      WITH itineraries_with_stops AS (
        SELECT
          destination_stops.itinerary_id AS itinerary_id,
          origin_stops.id                AS origin_stop_id,
          destination_stops.id           AS destination_stop_id
        FROM (
          SELECT id, itinerary_id, index
          FROM stops
          WHERE hub_id IN (?)
        ) as origin_stops
        JOIN (
          SELECT id, itinerary_id, index
          FROM stops
          WHERE hub_id IN (?)
        ) as destination_stops
        ON origin_stops.itinerary_id = destination_stops.itinerary_id
        WHERE origin_stops.index < destination_stops.index
      )
      SELECT
        itineraries.id                             AS itinerary_id,
        itineraries.mode_of_transport              AS mode_of_transport,
        itineraries_with_stops.origin_stop_id      AS origin_stop_id,
        itineraries_with_stops.destination_stop_id AS destination_stop_id
      FROM itineraries
      JOIN itineraries_with_stops ON itineraries.id = itineraries_with_stops.itinerary_id
      WHERE itineraries.id IN (?)
    ", origin_hub_ids, destination_hub_ids, ids])

    connection.exec_query(sanitized_query).to_a
  end

  def self.filter_by_hubs(origin_hub_ids, destination_hub_ids)
    where("
      id IN (
        SELECT d_stops.itinerary_id
        FROM (
          SELECT id, itinerary_id, index
          FROM stops
          WHERE hub_id IN (?)
        ) as o_stops
        JOIN (
          SELECT id, itinerary_id, index
          FROM stops
          WHERE hub_id IN (?)
        ) as d_stops
        ON o_stops.itinerary_id = d_stops.itinerary_id
        WHERE o_stops.index < d_stops.index
      )
    ", origin_hub_ids, destination_hub_ids)
  end


  def self.for_locations(shipment, trucking_data)
    if trucking_data && trucking_data["pre_carriage"]
      start_hub_ids = trucking_data["pre_carriage"].keys
      start_hubs = Hub.where(id: start_hub_ids)
    else
      start_city = shipment.origin_nexus
      start_hubs = start_city.hubs.where(tenant_id: shipment.tenant_id)
      start_hub_ids = start_hubs.ids
    end

    if trucking_data && trucking_data["on_carriage"]
      end_hub_ids = trucking_data["on_carriage"].keys
      end_hubs = Hub.where(id: end_hub_ids)
    else
      end_city = shipment.destination_nexus
      end_hubs = end_city.hubs.where(tenant_id: shipment.tenant_id)
      end_hub_ids = end_hubs.ids
    end

    itineraries = shipment.tenant.itineraries.filter_by_hubs(start_hub_ids, end_hub_ids)

    { itineraries: itineraries.to_a, origin_hubs: start_hubs, destination_hubs: end_hubs }
  end

  def self.update_hubs
    its = Itinerary.all
    its.each do |it|
      hub_arr = []
      hubs = it.stops.order(:index).each do |s|
        hub_arr << { hub_id: s.hub_id, index: s.index }
      end
      it.hubs = hub_arr
      it.save!
    end
  end

  def as_options_json(options={})
    new_options = options.reverse_merge(
      include: {
        stops: {
          include: {
            hub: {
              include: {
                nexus:    { only: %i[id name] },
                location: { only: %i[longitude latitude] }
              },
              only:    %i[id name]
            }
          },
          only:    %i[id index]
        }
      },
      only:    %i[id name mode_of_transport]
    )
    as_json(new_options)
  end

  def as_pricing_json(_options={})
    new_options = {
      users_with_pricing: users_with_pricing,
      pricing_count:      pricing_count
    }.merge(attributes)
    # as_json(new_options)
  end

  private

  def must_have_stops
    errors.add(:base, "Itinerary must have stops") if stops.empty?
  end
end
