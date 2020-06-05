# frozen_string_literal: true

module Legacy
  class Itinerary < ApplicationRecord # rubocop:disable Metrics/ClassLength
    include PgSearch::Model

    MODES_OF_TRANSPORT = %w[
      ocean
      air
      rail
      truck
    ].freeze
    self.table_name = 'itineraries'
    belongs_to :tenant
    has_many :stops, dependent: :destroy
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    has_many :layovers,  dependent: :destroy
    has_many :shipments, dependent: :destroy
    has_many :trips,     dependent: :destroy
    has_many :notes,     dependent: :destroy
    has_many :margins,   dependent: :destroy, class_name: 'Pricings::Margin'
    has_many :rates, class_name: 'Pricings::Pricing', dependent: :destroy
    has_many :hubs,      through: :stops
    belongs_to :origin_hub, class_name: 'Legacy::Hub'
    belongs_to :destination_hub, class_name: 'Legacy::Hub'
    has_many :map_data,  dependent: :destroy
    scope :for_mot, ->(mot_scope_ids) { where(mot_scope_id: mot_scope_ids) }
    scope :for_tenant, ->(tenant_id) { where(tenant_id: tenant_id) }

    validate :must_have_stops
    pg_search_scope :list_search, against: %i[name], using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :mot_search, against: %i[mode_of_transport], using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :transshipment_search, against: %i[transshipment], using: {
      tsearch: { prefix: true }
    }
    scope :ordered_by, ->(col, desc = false) { order(col => desc.to_s == 'true' ? :desc : :asc) }
    validates :origin_hub_id, uniqueness: { scope: %i[destination_hub_id tenant_id transshipment mode_of_transport] }
    validates :mode_of_transport, inclusion: { in: MODES_OF_TRANSPORT }

    def generate_schedules_from_sheet(stops:, # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
                                      start_date:,
                                      end_date:,
                                      tenant_vehicle_id:,
                                      closing_date:,
                                      vessel:,
                                      voyage_code:,
                                      load_type:,
                                      sandbox: nil)
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
      if %w[cargo_item lcl].include?(raw_load_type.downcase.strip)
        'cargo_item'
      else
        'container'
      end
    end

    def default_generate_schedules(end_date:, base_pricing: true, sandbox: nil) # rubocop:disable Metrics/AbcSize
      finish_date = end_date || DateTime.now + 21.days
      association = base_pricing ? rates : pricings
      tenant_vehicle_ids = association.where(sandbox_id: sandbox&.id).pluck(:tenant_vehicle_id).uniq
      stops_in_order = stops.where(sandbox_id: sandbox&.id).order(:index)
      tenant_vehicle_ids.each do |tv_id|
        %w[container cargo_item].each do |load_type|
          existing_trip = trips.where(tenant_vehicle_id: tv_id, load_type: load_type, sandbox_id: sandbox&.id).first
          steps_in_order = if existing_trip
                             (existing_trip.end_date - existing_trip.start_date) / 86_400
                           else
                             rand(20..50)
                           end
          generate_weekly_schedules(
            stops_in_order: stops_in_order,
            steps_in_order: [steps_in_order],
            start_date: DateTime.now,
            end_date: finish_date,
            ordinal_array: [1, 5],
            tenant_vehicle_id: tv_id,
            closing_date_buffer: 4,
            load_type: load_type,
            sandbox: sandbox
          )
        end
      end
    end

    def generate_weekly_schedules(stops_in_order:, # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
                                  steps_in_order:,
                                  start_date:,
                                  end_date:,
                                  ordinal_array:,
                                  tenant_vehicle_id:,
                                  closing_date_buffer: 4,
                                  load_type:,
                                  sandbox: nil)
      results = {
        layovers: [],
        trips: []
      }

      tmp_date = start_date.is_a?(Date)      ? start_date : DateTime.parse(start_date)
      end_date_parsed = end_date.is_a?(Date) ? end_date   : DateTime.parse(end_date)

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
            load_type: parse_load_type(load_type),
            sandbox_id: sandbox&.id
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
                trip_id: trip.id,
                sandbox_id: sandbox&.id
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
                closing_date: nil,
                sandbox_id: sandbox&.id
              }
            end
          end
        end

        tmp_date += 1.day
      end

      Legacy::Layover.import(stop_data)

      results[:trips]
    end

    def prep_schedules(limit) # rubocop:disable Metrics/AbcSize
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
            tenant_id: tenant_id,
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
      get_itineraries_with_dedicated_pricings(user.id, user.tenant_id)
    end

    def modes_of_transport
      exists = ->(mot) { !Itinerary.where(mode_of_transport: mot).limit(1).empty? }
      {
        ocean: exists.call('ocean'),
        air: exists.call('air'),
        rail: exists.call('rail'),
        truck: exists.call('truck')
      }
    end

    def first_stop
      stops.reorder(index: :asc).limit(1).first
    end

    def last_stop
      stops.reorder(index: :desc).limit(1).first
    end

    def origin_stops
      stops.where(hub: origin_hub)
    end

    def destination_stops
      stops.where(hub: destination_hub)
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
      origin_stops.joins(:hub).pluck('hubs.nexus_id')
    end

    def destination_nexus_ids
      destination_stops.joins(:hub).pluck('hubs.nexus_id')
    end

    def origin_hub_ids
      [origin_hub_id]
    end

    def destination_hub_ids
      [destination_hub_id]
    end

    def origin_nexuses
      Nexus.where(id: origin_nexus_ids)
    end

    def destination_nexuses
      Nexus.where(id: destination_nexus_ids)
    end

    def users_with_pricing
      rates.where.not(user_id: nil).count
    end

    def pricing_count
      rates.count
    end

    def routes # rubocop:disable Metrics/AbcSize
      stops.order(:index).to_a.combination(2).map do |stop_array|
        if !stop_array[0].hub || !stop_array[1].hub
          stop_array[0].itinerary.destroy
          next
        end
        {
          origin: stop_array[0].hub.lng_lat_array,
          destination: stop_array[1].hub.lng_lat_array,
          line: {
            type: 'LineString',
            id: "#{id}-#{stop_array[0].index}",
            coordinates: [stop_array[0].hub.lng_lat_array, stop_array[1].hub.lng_lat_array]
          }
        }
      end
    end

    def detailed_hash(stop_array, options = {}) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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

    def ordered_hub_ids
      stops.order(index: :asc).pluck(:hub_id)
    end

    def generate_map_data
      routes.each do |route_data|
        route_data[:tenant_id] = tenant_id
        map_data.find_or_create_by!(route_data)
      end
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

    def self.for_addresses(shipment, trucking_data) # rubocop:disable Metrics/AbcSize
      if trucking_data && trucking_data['pre_carriage']
        start_hub_ids = trucking_data['pre_carriage'].keys
        start_hubs = Hub.where(id: start_hub_ids)
      else
        start_city = shipment.origin_nexus
        start_hubs = start_city.hubs.where(tenant_id: shipment.tenant_id)
        start_hub_ids = start_hubs.ids
      end

      if trucking_data && trucking_data['on_carriage']
        end_hub_ids = trucking_data['on_carriage'].keys
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
        hub_arr = it.stops.order(:index).map do |s|
          { hub_id: s.hub_id, index: s.index }
        end
        it.hubs = hub_arr
        it.save!
      end
    end

    def as_options_json(options = {})
      new_options = options.reverse_merge(
        include: {
          stops: {
            include: {
              hub: {
                include: {
                  nexus: { only: %i[id name] },
                  address: { only: %i[longitude latitude geocoded_address] }
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

    def as_pricing_json(_options = {})
      new_options = {
        users_with_pricing: users_with_pricing,
        pricing_count: pricing_count
      }.merge(attributes)
      as_json(new_options)
    end

    private

    def must_have_stops
      errors.add(:base, 'Itinerary must have stops') if stops.empty?
    end
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
#  origin_hub_id      :bigint
#  sandbox_id         :uuid
#  tenant_id          :integer
#
# Indexes
#
#  index_itineraries_on_destination_hub_id  (destination_hub_id)
#  index_itineraries_on_mode_of_transport   (mode_of_transport)
#  index_itineraries_on_name                (name)
#  index_itineraries_on_origin_hub_id       (origin_hub_id)
#  index_itineraries_on_sandbox_id          (sandbox_id)
#  index_itineraries_on_tenant_id           (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (destination_hub_id => hubs.id)
#  fk_rails_...  (origin_hub_id => hubs.id)
#
