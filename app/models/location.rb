class Location < ApplicationRecord
  has_many :user_locations
  has_many :users, through: :user_locations, dependent: :destroy
  has_many :shipments
  has_many :contacts

  has_many :hubs, foreign_key: :nexus_id do
    def tenant_id(tenant_id)
      where(tenant_id: tenant_id)
    end
  end
  has_many :routes
  has_many :stops, through: :hubs
  belongs_to :country, optional: true

  scope :nexus, -> { where(location_type: "nexus") }

  # Geocoding
  geocoded_by :geocoded_address

  reverse_geocoded_by :latitude, :longitude do |location, results|
    if geo = results.first
      premise_data = geo.address_components.find do |address_component|
        address_component["types"] == ["premise"]
      end || {}
      location.premise          = premise_data["long_name"]
      location.street_number    = geo.street_number
      location.street           = geo.route
      location.street_address   = geo.street_number.to_s + " " + geo.route.to_s
      location.geocoded_address = geo.address
      location.city             = geo.city
      location.zip_code         = geo.postal_code
      
      location.country          = Country.find_by(code: geo.country_code)
    end
    location
  end

  # Class methods
  def self.get_geocoded_location(user_input, hub_id, truck_carriage)
    if truck_carriage
      geocoded_location(user_input)
    else
      Location.where(id: hub_id).first
    end
  end

  def self.from_short_name(input, location_type)
    city, country_name = *input.split(" ,")
    country = Country.geo_find_by_name(country_name)
    location = Location.find_by(city: city, country: country, location_type: location_type) 
    return location unless location.nil?

    temp_location = Location.new(geocoded_address: input)
    temp_location.geocode
    temp_location.reverse_geocode
    
    location = Location.find_by(city: temp_location.city, country: temp_location.country, location_type: location_type) 
    return location unless location.nil?

    location = temp_location

    location.name = city
    location.location_type = location_type
    location.save!
    location
  end

  def set_geocoded_address_from_fields!
    rawAddress = "#{street} #{street_number}, #{premise}, #{zip_code} #{city}, #{country.try(:name)}"
    self.geocoded_address = rawAddress.remove_extra_spaces
  end

  def geocode_from_address_fields!
    self.set_geocoded_address_from_fields!
    self.geocode
    self.save!
    self
  end

  def self.get_trucking_city(string)
    l = new(geocoded_address: string)
    l.geocode
    l.reverse_geocode
    
    return l.city
  end

  def self.geocode_all_from_address_fields!(options = {})
    # Example Usage:
    #   1. Location.geocode_all_from_address_fields
    #         Updates locations with nil geocoded_address
    #         Return Array of updated locations 
    #   2. Location.geocode_all_from_address_fields(force: true)
    #         Updates all locations
    #         Return Array of all locations 

    filter = options[:force] ? nil : { geocoded_address: nil } 
    Location.where(filter).map(&:geocode_from_address_fields!)
  end

  def self.create_and_geocode(raw_location_params)
    location = Location.find_or_create_by(location_params(raw_location_params))
    location.geocode_from_address_fields! if location.geocoded_address.nil?
    
    location
  end

  def self.geocoded_location(user_input)
    location = Location.new(geocoded_address: user_input)
    location.geocode
    location.reverse_geocode
    location.save!
    location
  end

  def self.new_from_raw_params(raw_location_params)
    new(location_params(raw_location_params))
  end

  def self.create_from_raw_params!(raw_location_params)
    create!(location_params(raw_location_params))
  end

  def self.nexuses
    where(location_type: 'nexus')
  end

  def self.nexuses_client(client)
    client.pricings.map{|p| p.route}.map { |r| r.get_nexuses }.flatten.uniq
  end

  def self.nexuses_prepared
    nexuses.pluck(:id, :name).to_h.invert
  end

  def self.nexuses_prepared_client(client)
    nexuses_client(client).pluck(:id, :name).to_h.invert
  end

  def self.all_with_primary_for(user)
    locations = user.locations
    locations.map do |loc|
      prim = {primary: loc.is_primary_for?(user)}
      loc.attributes.merge(prim)
    end
  end


  # Instance methods

  def set_country_by_name!(name)
    self.country = Country.geo_find_by_name(name)
  end

  def set_country_by_code!(code)
    self.country = Country.find_by(code: code)
  end

  def is_primary_for?(user)
    user_loc = UserLocation.find_by(location_id: self.id, user_id: user.id)
    if user_loc.nil?
      raise "This 'Location' object is not associated with a user!"
    else
      return !!user_loc.primary
    end
  end

  def hubs_by_type(hub_type, tenant_id)
    hubs.where(hub_type: hub_type, tenant_id: tenant_id)
  end
  
  def hubs_by_type_seeder(hub_type, tenant_id)
    hubs = self.hubs.where(hub_type: hub_type, tenant_id: tenant_id)
    if hubs.length < 1
      case hub_type
      when 'ocean'
        name = "#{self.name} Port"
      when 'air'
        name = "#{self.name} Airport"
      when 'rail'
        name = "#{self.name} Railyard"
      else
        name = self.name
      end
      hub =  self.hubs.create!(hub_type: hub_type, tenant_id: tenant_id, name: name, latitude: self.latitude, longitude: self.longitude, location_id: self.id, nexus_id: self.id)
      return self.hubs.where(hub_type: hub_type, tenant_id: tenant_id)
    else
      hubs
    end
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
    "#{self.city}, #{self.country.name}"
  end

  def full_address
    part1 = [street, street_number].delete_if(&:blank?).join(" ")
    part2 = [zip_code, city, country.name].delete_if(&:blank?).join(", ")
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
    distances = locations.map do |location|
      Geocoder::Calculations.distance_between(
        [self.latitude, self.longitude], 
        [location.latitude, location.longitude]
      )
    end
    lowest_distance = distances.reject(&:nan?).min
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

  def furthest_hub(hubs)
    hubs.max do |hub_x, hub_y| 
      hub_x.distance_to(self) <=> hub_y.distance_to(self)
    end
  end

  def get_zip_code
    if self.zip_code
      self.zip_code.gsub(' ', '')
    else
      self.reverse_geocode
      self.zip_code.try(:gsub, ' ', '')
    end
  end

  def to_custom_hash
    custom_hash = { country: country.try(:name) }
    [
      :id, :city, :street, :street_number, :zip_code,
      :geocoded_address, :latitude, :longitude,
      :location_type, :name
    ].each do |attribute|
      custom_hash[attribute] = self[attribute]
    end

    custom_hash
  end

  private

  def self.location_params(raw_location_params)
    country = Country.geo_find_by_name(raw_location_params["country"])

    raw_location_params.try(:permit,
      :latitude, :longitude, :geocoded_address, :street,
      :street_number, :zip_code, :city
    )

    raw_location_params.to_h.merge(country: country)
  end  
end
