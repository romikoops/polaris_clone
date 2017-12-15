class Route < ApplicationRecord
  extend RouteTools
  has_many :hub_routes
  has_many :pricings
  has_many :shipments
  has_many :schedules, through: :hub_routes
  belongs_to :origin_nexus, class_name: "Location"
  belongs_to :destination_nexus, class_name: "Location"
  # belongs_to :customer, class_name: "User"
  has_many :user_route_discounts

  # Filterrific
  filterrific :default_filter_params => { :sorted_by => 'trade_direction_asc' },
              :available_filters => %w(
                sorted_by
                search_query
              )

  self.per_page = 10 # default for will_paginate

  scope :search_query, lambda { |query|
    return nil if query.blank?
    # condition query, parse into individual keywords
    terms = query.to_s.gsub(',', '').downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # prepend and append '%', remove duplicate '%'s
    terms = terms.map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 1
    where(
      terms.map {
        or_clauses = [
          "LOWER(routes.name) LIKE ?",
        ].join(' OR ')
        "(#{or_clauses})"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^trade_direction_/
      order("routes.trade_direction #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  # Class methods
  def self.options_for_sorted_by
    [
      ['Export', 'trade_direction_asc'],
      ['Import', 'trade_direction_desc']
    ]
  end

  def self.get_route(origin, destination)
    number_of_hubs = Location.all_hubs.count
    number_of_closest_hubs = number_of_hubs >= 3 ? 3 : number_of_hubs
    origin_hubs = origin.closest_hubs[0...number_of_closest_hubs]
    destination_hubs = destination.closest_hubs[0...number_of_closest_hubs]

    routes = []
    origin_hubs.each do |o_hub|
      destination_hubs.each do |d_hub|
        routes << Route.find_by(starthub: o_hub, endhub: d_hub)
      end
    end

    routes = routes.compact
    routes.first
  end

  def self.get_mode_of_transport(stop1, stop2)
    if stop1.location_type == "hub_train" || stop2.location_type == "hub_train"
      return "train"
    else
      return "vessel"
    end
  end

  # Instance methods
  def stops_as_string
    self.stops.pluck(:hub_name).join(" \u2192 ")
  end

  def starthub
    self.stops.first
  end

  def endhub
    self.stops.last
  end

  def get_all_pricings
    s = self.stops
    ocean_pricings = []
    train_pricings = []
    for i in 0..(s.length - 2)
      case s[i+1].location_type
      when "hub_ocean"
        pricings = Route.where(starthub_name: s[i].hub_name, endhub_name: s[i+1].hub_name, mode_of_transport: "ocean")
      when "hub_train"
        pricings = Route.where(starthub_name: s[i].hub_name, endhub_name: s[i+1].hub_name, mode_of_transport: "train")
      else
        raise "Unknown location type"
      end

      ocean_pricings << pricings if not pricings.nil?
      train_pricings << pricings if not pricings.nil?
    end
    pre_carriage = TruckingPricing.first
    post_carriage = TruckingPricing.first
    { pre_carriage: pre_carriage, ocean_pricings: ocean_pricings, train_pricings: train_pricings, post_carriage: post_carriage }
  end

  def total_price
    pricings = get_all_pricings
    total = 0

    pricings.each do |pricing|
      total += pricing.price
    end
    total.round(2).to_f
  end

  def self.create_from_schedule(schedule, tenant_id)
    nrt = Route.create(origin_id: schedule[:origin_id], destination_id: schedule[:destination_id], tenant_id: tenant_id)
    return nrt
  end

  def self.for_locations(origin, destination, radius = 100)
    start_city, start_city_dist = origin.closest_location_with_distance
    end_city, end_city_dist = destination.closest_location_with_distance
    
    if start_city_dist > radius || end_city_dist > radius
      start_city = end_city = nil
    end
    
    find_by(origin_nexus_id: start_city.id, destination_nexus_id: end_city.id)
  end

  def self.ids_dedicated(user = nil)
    get_routes_with_dedicated_pricings(user.id, user.tenant_id)
  end

  def next_departure
    self.schedules.where("etd > ?", DateTime.now).order(:etd).limit(1).first
  end 

  def lcl_price(cargo)
    cargo.weight_or_volume * lcl_m3_ton_price    
  end

  def fcl_price(container)
    case container.size_class    
    when "20_dc"
      fcl_20f_price
    when "40_dc"
      fcl_40f_price
    when "40_hq"
      fcl_40f_hq_price
    else
      raise "Unknown container size class!"
    end
  end

  def modes_of_transport
    exists = -> mot { schedules.where(mode_of_transport: mot).limit(1).size > 0 }    
    {
      ocean: exists.('ocean'),
      air:   exists.('air'),
      rails: exists.('rails')
    }
  end

  def detailed_hash(options = {})
    return_h = attributes
    return_h[:origin_nexus]       = origin_nexus.name                    if options[:nexus_names] 
    return_h[:destination_nexus]  = destination_nexus.name               if options[:nexus_names]
    return_h[:modes_of_transport] = modes_of_transport                   if options[:modes_of_transport]
    return_h[:next_departure]     = next_departure                       if options[:next_departure]
    return_h[:dedicated]          = options[:ids_dedicated].include?(id) unless options[:ids_dedicated].nil?
    return_h
  end
end