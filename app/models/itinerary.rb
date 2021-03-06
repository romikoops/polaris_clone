# frozen_string_literal: true

class Itinerary < Legacy::Itinerary
  belongs_to :organization, class_name: "Organizations::Organization"
  has_many :stops, dependent: :destroy
  has_many :layovers, dependent: :destroy
  has_many :trips, dependent: :destroy
  has_many :notes, dependent: :destroy, as: :target
  has_many :rates, class_name: "Pricings::Pricing", dependent: :destroy
  has_many :hubs, through: :stops

  self.per_page = 12

  def generate_schedules_from_sheet(
    stops:,
    start_date:,
    end_date:,
    tenant_vehicle_id:,
    closing_date:,
    vessel:,
    voyage_code:,
    load_type:
  )
    results = {
      layovers: [],
      trips: []
    }
    trip = trips.new(
      start_date: start_date,
      end_date: end_date,
      tenant_vehicle_id: tenant_vehicle_id,
      vessel: vessel,
      voyage_code: voyage_code,
      closing_date: closing_date,
      load_type: parse_load_type(load_type)
    )
    return results unless trip.save

    results[:trips] << trip
    stops.each do |stop|
      data =
        if stop.index.zero?
          {
            closing_date: closing_date,
            eta: nil,
            etd: start_date,
            stop_index: stop.index,
            itinerary_id: stop.itinerary_id,
            stop_id: stop.id
          }
        else
          {
            eta: end_date,
            etd: nil,
            stop_index: stop.index,
            itinerary_id: stop.itinerary_id,
            stop_id: stop.id
          }
        end
      layover = trip.layovers.find_or_create_by!(data)
      results[:layovers] << layover
    end
    results
  end

  def parse_load_type(raw_load_type)
    if raw_load_type.respond_to?(:downcase) && %w[cargo_item lcl].include?(raw_load_type.downcase.strip)
      "cargo_item"
    else
      "container"
    end
  end

  def generate_weekly_schedules(stops_in_order:,
    steps_in_order:,
    start_date:,
    end_date:,
    ordinal_array:,
    tenant_vehicle_id:,
    load_type:, closing_date_buffer: 4)
    results = {
      layovers: [],
      trips: []
    }

    tmp_date = start_date.is_a?(Date) ? start_date : DateTime.parse(start_date)
    end_date_parsed = end_date.is_a?(Date) ? end_date : DateTime.parse(end_date)

    stop_data = []
    steps_in_order = steps_in_order.map(&:to_i)

    while tmp_date < end_date_parsed
      if ordinal_array.include?(tmp_date.wday)
        journey_start = tmp_date.midday
        closing_date = journey_start - closing_date_buffer.days
        journey_end = journey_start + steps_in_order.sum.days

        trip = trips.new(
          start_date: journey_start,
          end_date: journey_end,
          tenant_vehicle_id: tenant_vehicle_id,
          closing_date: closing_date,
          load_type: parse_load_type(load_type)
        )

        unless trip.save
          tmp_date += 1.day
          next
        end

        results[:trips] << trip

        stops_in_order.each do |stop|
          if stop.index.zero?
            stop_data << {
              eta: nil,
              etd: journey_start,
              stop_index: stop.index,
              itinerary_id: stop.itinerary_id,
              stop_id: stop.id,
              closing_date: closing_date,
              trip_id: trip.id
            }
          else
            journey_start += steps_in_order[stop.index - 1].days
            stop_data << {
              eta: journey_start,
              etd: journey_start + 1.day,
              stop_index: stop.index,
              itinerary_id: stop.itinerary_id,
              stop_id: stop.id,
              trip_id: trip.id,
              closing_date: nil
            }
          end
        end
      end

      tmp_date += 1.day
    end

    Layover.import(stop_data)

    results[:trips]
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
          itinerary_id: id,
          eta: lc[1].eta,
          etd: lc[0].etd,
          mode_of_transport: lc[0].itinerary.mode_of_transport,
          hub_route_key: "#{lc[0].stop.hub_id}-#{lc[1].stop.hub_id}",
          organization_id: organization_id,
          trip_id: lc[0].trip_id,
          origin_layover_id: lc[0].id,
          destination_layover_id: lc[1].id,
          closing_date: lc[0].closing_date
        )
      end
    end

    schedules
  end

  def self.ids_dedicated(user = nil)
    get_itineraries_with_dedicated_pricings(user.id, user.organization_id)
  end

  def modes_of_transport
    exists = ->(mot) { !Itinerary.where(mode_of_transport: mot).limit(1).empty? }
    {
      ocean: exists.call("ocean"),
      air: exists.call("air"),
      rail: exists.call("rail"),
      truck: exists.call("truck")
    }
  end

  def first_stop
    stops.order(index: :asc).limit(1).first
  end

  def last_stop
    stops.order(index: :desc).limit(1).first
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

  def hub_ids_for_target(target)
    try("#{target}_hub_ids".to_sym)
  end

  def origin_nexus_ids
    origin_stops.joins(:hub).pluck("hubs.nexus_id")
  end

  def destination_nexus_ids
    destination_stops.joins(:hub).pluck("hubs.nexus_id")
  end

  def origin_nexuses
    Nexus.where(id: origin_nexus_ids)
  end

  def destination_nexuses
    Nexus.where(id: destination_nexus_ids)
  end

  def users_with_pricing
    pricings.where.not(user_id: nil).count
  end

  def user_has_pricing(user)
    ids = [user.id, user&.agency&.agency_manager_id].compact
    pricings.exists?(user_id: ids)
  end

  def pricing_count
    pricings.count
  end

  def dedicated_pricing_count(user)
    dedicated_pricings_count = pricings.where(user_id: user.id).count
    open_pricings_count = pricings.where(user_id: nil).count
    {
      dedicated_pricings_count: dedicated_pricings_count,
      open_pricings_count: (dedicated_pricings_count - open_pricings_count).abs
    }
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
          type: "LineString",
          id: "#{id}-#{stop_array[0].index}",
          coordinates: [stop_array[0].hub.lng_lat_array, stop_array[1].hub.lng_lat_array]
        }
      }
    end
  end

  def detailed_hash(stop_array, options = {})
    origin = stop_array[0]
    destination = stop_array[1]
    return_h = attributes
    return_h[:origin_nexus] = origin.hub.nexus.name if options[:nexus_names]
    return_h[:destination_nexus] = destination.hub.nexus.name if options[:nexus_names]
    return_h[:origin_nexus_id] = origin.hub.nexus.id if options[:nexus_ids]
    return_h[:destination_nexus_id] = destination.hub.nexus.id if options[:nexus_ids]
    return_h[:origin_hub_id] = origin.hub.id if options[:hub_ids]
    return_h[:destination_hub_id] = destination.hub.id if options[:hub_ids]
    return_h[:origin_hub_name] = origin.hub.name if options[:hub_names]
    return_h[:destination_hub_name] = destination.hub.name if options[:hub_names]
    return_h[:origin_stop_id] = origin.id if options[:stop_ids]
    return_h[:destination_stop_id] = destination.id if options[:stop_ids]
    return_h[:modes_of_transport] = modes_of_transport if options[:modes_of_transport]
    return_h[:next_departure] = next_departure if options[:next_departure]
    return_h[:dedicated] = options[:ids_dedicated].include?(id) unless options[:ids_dedicated].nil?
    return_h
  end

  def ordered_hub_ids
    stops.order(index: :asc).pluck(:hub_id)
  end

  def generate_map_data
    routes.each do |route_data|
      route_data[:organization_id] = organization_id
      map_data.find_or_create_by!(route_data)
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

  def available_counterpart_hub_ids_for_target_hub_ids(target, target_hub_ids)
    raise ArgumentError unless %w[origin destination].include?(target)

    target_hub_ids.map { |target_hub_id|
      next unless ordered_hub_ids.include?(target_hub_id)

      target_idx = ordered_hub_ids.index(target_hub_id)

      target_range = target == "origin" ? 0...target_idx : (target_idx + 1)..-1

      ordered_hub_ids[target_range]
    }.compact.flatten.uniq
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

  def self.for_addresses(shipment, trucking_data)
    if trucking_data && trucking_data["pre_carriage"]
      start_hub_ids = trucking_data["pre_carriage"].keys
      start_hubs = Hub.where(id: start_hub_ids)
    else
      start_city = shipment.origin_nexus
      start_hubs = start_city.hubs.where(organization_id: shipment.organization_id)
      start_hub_ids = start_hubs.ids
    end

    if trucking_data && trucking_data["on_carriage"]
      end_hub_ids = trucking_data["on_carriage"].keys
      end_hubs = Hub.where(id: end_hub_ids)
    else
      end_city = shipment.destination_nexus
      end_hubs = end_city.hubs.where(organization_id: shipment.organization_id)
      end_hub_ids = end_hubs.ids
    end

    itineraries = shipment.organization.itineraries.filter_by_hubs(start_hub_ids, end_hub_ids)

    {itineraries: itineraries.to_a, origin_hubs: start_hubs, destination_hubs: end_hubs}
  end

  def as_options_json(options = {})
    new_options = options.reverse_merge(
      include: {
        stops: {
          include: {
            hub: {
              include: {
                nexus: {only: %i[id name]},
                address: {only: %i[longitude latitude geocoded_address]}
              },
              only: %i[id name]
            }
          },
          only: %i[id index]
        }
      },
      only: %i[id name mode_of_transport]
    )
    as_json(new_options)
  end

  def as_pricing_json(options = {})
    {
      users_with_pricing: users_with_pricing,
      pricing_count: pricing_count
    }.merge(attributes)
  end

  def as_user_pricing_json(user, options = {})
    new_options = {
      user_has_pricing: user_has_pricing(user)
    }.merge(dedicated_pricing_count(user))
    as_options_json(options).merge(new_options)
  end

  private

  def must_have_stops
    errors.add(:base, "Itinerary must have stops") if stops.empty?
  end
end

# == Schema Information
#
# Table name: itineraries
#
#  id                 :bigint           not null, primary key
#  mode_of_transport  :string
#  name               :string
#  transshipment      :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  destination_hub_id :bigint
#  organization_id    :uuid
#  origin_hub_id      :bigint
#  sandbox_id         :uuid
#  tenant_id          :integer
#  upsert_id          :uuid
#
# Indexes
#
#  index_itineraries_on_destination_hub_id  (destination_hub_id)
#  index_itineraries_on_mode_of_transport   (mode_of_transport)
#  index_itineraries_on_name                (name)
#  index_itineraries_on_organization_id     (organization_id)
#  index_itineraries_on_origin_hub_id       (origin_hub_id)
#  index_itineraries_on_sandbox_id          (sandbox_id)
#  index_itineraries_on_tenant_id           (tenant_id)
#  itinerary_upsert                         (upsert_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (destination_hub_id => hubs.id) ON DELETE => cascade
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (origin_hub_id => hubs.id) ON DELETE => cascade
#
