class Location < ApplicationRecord
  has_many :user_locations
  has_many :users, through: :user_locations
  has_many :shipments
  has_many :contacts

  has_many :routes
  has_many :hubs

  # Geocoding
  geocoded_by :geocoded_address
  # geocoded_by :full_address
  # reverse_geocoded_by :latitude, :longitude, :address => :geocoded_address
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.street_number = geo.street_number
      obj.street = geo.route
      obj.street_address = geo.street_number.to_s + " " + geo.route.to_s
      obj.geocoded_address = geo.address
      obj.country = geo.country
      obj.city = geo.city
      obj.zip_code = geo.postal_code
    end
  end

  # Class methods
  def self.get_geocoded_location(user_input, hub_id, truck_carriage)
    if truck_carriage
      geocoded_location(user_input)
    else
      return Location.find(hub_id)
    end
  end

  def self.create_and_geocode(location_params)
    if !location_params[:geocoded_address]
      str = location_params[:street_address].to_s + " " + location_params[:city].to_s + " " + location_params[:zip_code].to_s + " " + location_params[:country].to_s
      location_params[:geocoded_address] = str
    end
    loc = Location.find_or_create_by(
    latitude: location_params[:latitude],
    longitude: location_params[:longitude],
    geocoded_address: location_params[:geocoded_address],
    street: location_params[:street],
    street_address: location_params[:street_address],
    street_number: location_params[:street_number],
    zip_code: location_params[:zip_code],
    city: location_params[:city],
    country: location_params[:country])
    loc.geocode
    loc.reverse_geocode
    
    return loc
  end
  def self.geocoded_location(user_input)

    location = Location.new(geocoded_address: user_input)
    location.geocode
    location.reverse_geocode
    return location
  end

  def get_zip_code
    if self.zip_code
      return self.zip_code
    else
      self.geocoded_address
      self.reverse_geocode
      return self.zip_code
    end
  end

  def self.end_ports
    Location.where("location_type = ?", "end_port")
  end

  def self.new_from_params(location_params)
    Location.new(
    latitude: location_params[:latitude],
    longitude: location_params[:longitude],
    geocoded_address: location_params[:geocoded_address],
    street: location_params[:street],
    street_number: location_params[:street_number],
    zip_code: location_params[:zip_code],
    city: location_params[:city],
    country: location_params[:country])
  end

  def self.all_hubs
    Location.where("location_type LIKE ?", "%hub_%")
  end

  def self.all_hubs_dedicated(customer)
    locs = Location.where("location_type LIKE ?", "%hub_%")
    prcs = customer.pricings
    dedicated_locs = []
    locs.each do |loc|
      prcs.each do |p|
        if p.origin == loc || p.destination == loc
          dedicated_locs << loc
        end
      end
    end
    dedicated_locs
  end

  def self.ocean_hubs(collection)
    Location.where(id: collection.map(&:id)).where("location_type LIKE ?", "%hub_ocean%")
  end

  def self.train_hubs(collection)
    Location.where(id: collection.map(&:id)).where("location_type LIKE ?", "%hub_train%")
  end

  def self.all_hubs_prepared
    o = self.ocean_hubs(self.all_hubs)
    t = self.train_hubs(self.all_hubs)

    prepared_hubs = {}
    o.each do |hub|
      prepared_hubs.merge!({ hub.id => "#{hub.hub_name} | #{hub.pretty_hub_type}"})
    end
    t.each do |hub|
      prepared_hubs.merge!({ hub.id => "#{hub.hub_name} | #{hub.pretty_hub_type}"})
    end
    prepared_hubs.invert
  end

  def self.all_hubs_prepared_dedicated(customer)
    o = self.ocean_hubs(self.all_hubs_dedicated(customer))
    t = self.train_hubs(self.all_hubs_dedicated(customer))

    prepared_hubs = {}
    o.each do |hub|
      prepared_hubs.merge!({ hub.id => "#{hub.hub_name} | #{hub.pretty_hub_type}"})
    end
    t.each do |hub|
      prepared_hubs.merge!({ hub.id => "#{hub.hub_name} | #{hub.pretty_hub_type}"})
    end
    prepared_hubs.invert
  end

  # Instance methods
  def hubs_by_type(hub_type)
    hubs.where(hub_type: hub_type)
  end

  def pretty_hub_type
    case self.location_type
    when 'hub_train'
      "Train Hub"
    when 'hub_ocean'    
      "Port"
    else
      raise "Unknown Hub Type!"
    end
  end

  def city_country
    "#{city}, #{country}"
  end

  def full_address
    part1 = [street, street_number].delete_if(&:blank?).join(" ")
    part2 = [zip_code, city, country].delete_if(&:blank?).join(", ")
    [part1, part2].delete_if(&:blank?).join(", ")
  end

  def lat_lng_string
    "#{latitude},#{longitude}"
  end

  def closest_hub
    hubs = Location.where(location_type: "nexus")
    distances = []
    hubs.each do |hub|
      distances << Geocoder::Calculations.distance_between([self.latitude, self.longitude], [hub.latitude, hub.longitude])
    end

    lowest_distance = distances.min
    hubs[distances.find_index(lowest_distance)]
  end

  def closest_location_with_distance
    locations = Location.where(location_type: "nexus")
    distances = []

    locations.each do |location|
      
      distances << Geocoder::Calculations.distance_between([self.latitude, self.longitude], [location.latitude, location.longitude])
    end

    lowest_distance = distances.min
    
    return locations[distances.find_index(lowest_distance)], lowest_distance
  end

  def closest_hubs
    hubs = Location.where(location_type: "nexus")
    distances = {}
    hubs.each_with_index do |hub, i|
      distances[i] = Geocoder::Calculations.distance_between([self.latitude, self.longitude], [hub.latitude, hub.longitude])
    end

    distances = distances.sort_by {|k,v| v}
    hubs_array = []
    distances.each do |key, value|
      hubs_array << hubs[key]
    end

    hubs_array
  end
end
