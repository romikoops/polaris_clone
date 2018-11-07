# frozen_string_literal: true

class Address < ApplicationRecord
  has_many :user_addresses
  has_many :users, through: :user_addresses, dependent: :destroy
  has_many :shipments
  has_many :contacts
  has_many :ports, foreign_key: :nexus_id
  has_many :ports
  has_one :hub

  # has_many :hubs, foreign_key: :nexus_id do
  #   def tenant_id(tenant_id)
  #     where(tenant_id: tenant_id)
  #   end
  # end
  has_many :routes
  has_many :stops, through: :hubs
  belongs_to :country, optional: true

  scope :nexus, -> { where(address_type: "nexus") }

  before_validation :sanitize_zip_code!

  # Geocoding
  geocoded_by :geocoded_address

  reverse_geocoded_by :latitude, :longitude do |address, results|
    if geo = results.first
      premise_data = geo.address_components.find do |address_component|
        address_component["types"] == ["premise"]
      end || {}
      address.premise          = premise_data["long_name"]
      address.street_number    = geo.street_number
      address.street           = geo.route
      address.street_address   = geo.street_number.to_s + " " + geo.route.to_s
      address.geocoded_address = geo.address
      address.city             = geo.city
      address.zip_code         = geo.postal_code

      address.country          = Country.find_by(code: geo.country_code)
    end

    address
  end

  # Class methods
  def self.get_geocoded_address(user_input, hub_id, truck_carriage)
    if truck_carriage
      geocoded_address(user_input)
    else
     Address.where(id: hub_id).first
    end
  end

  def self.from_short_name(input, address_type)
    city, country_name = *input.split(" ,")
    country = Country.geo_find_by_name(country_name)
    address = Address.find_by(city: city, country: country, address_type: address_type)
    return address unless address.nil?

    temp_address = Address.new(geocoded_address: input)
    temp_address.geocode
    temp_address.reverse_geocode

    address = Address.find_by(city: temp_address.city, country: temp_address.country, address_type: address_type)
    return address unless address.nil?

    address = temp_address

    address.name = city
    address.address_type = address_type
    address.save!
    address
  end

  def set_geocoded_address_from_fields!
    rawAddress = "#{street} #{street_number}, #{premise}, #{zip_code} #{city}, #{country.try(:name)}"
    self.geocoded_address = rawAddress.remove_extra_spaces
  end

  def geocode_from_address_fields!
    set_geocoded_address_from_fields!
    geocode
    save!
    self
  end

  def self.get_trucking_city(string)
    l = new(geocoded_address: string)
    l.geocode
    l.reverse_geocode

    l.city
  end

  def self.geocode_all_from_address_fields!(options={})
    # Example Usage:
    #   1.Address.geocode_all_from_address_fields
    #         Updates addresses with nil geocoded_address
    #         Return Array of updated addresses
    #   2.Address.geocode_all_from_address_fields(force: true)
    #         Updates all addresses
    #         Return Array of all addresses

    filter = options[:force] ? nil : { geocoded_address: nil }
   Address.where(filter).map(&:geocode_from_address_fields!)
  end

  def self.create_and_geocode(raw_address_params)
    address = Address.find_or_create_by(address_params(raw_address_params))
    address.geocode_from_address_fields! if address.geocoded_address.nil?
    address.reverse_geocode if address.zip_code.nil?
    address
  end

  def self.geocoded_address(user_input)
    address = Address.new(geocoded_address: user_input)
    address.geocode
    address.reverse_geocode
    address.save!
    address
  end

  def self.new_from_raw_params(raw_address_params)
    new(address_params(raw_address_params))
  end

  def self.create_from_raw_params!(raw_address_params)
    create!(address_params(raw_address_params))
  end

  def self.nexuses
    where(address_type: "nexus")
  end

  def self.nexuses_client(client)
    client.pricings.map(&:route).map(&:get_nexuses).flatten.uniq
  end

  def contains?(lat:, lng:)
    # TODO: Remove subqueries and write specs

  def self.nexuses_prepared_client(client)
    nexuses_client(client).pluck(:id, :name).to_h.invert
  end

  def self.all_with_primary_for(user)
    addresses = user.addresses
    addresses.map do |loc|
      prim = { primary: loc.is_primary_for?(user) }
      loc.to_custom_hash.merge(prim)
    end
  end

    results = ActiveRecord::Base.connection.execute(sanitized_query).first

    results['contains']
  end

  def names
    [postal_code, neighbourhood, city, province, country]
  end

  def is_primary_for?(user)
    user_loc = UserAddress.find_by(address_id: id, user_id: user.id)
    if user_loc.nil?
      raise "This 'Location' object is not associated with a user!"
    else
      return !!user_loc.primary
    end
  end

  

  def hubs_by_type_seeder(hub_type, tenant_id)
    hubs = self.hubs.where(hub_type: hub_type, tenant_id: tenant_id)
    if hubs.empty?
      name = case hub_type
             when "ocean"
               "#{self.name} Port"
             when "air"
               "#{self.name} Airport"
             when "rail"
               "#{self.name} Railyard"
             else
               self.name
             end
      hub =  self.hubs.create!(hub_type: hub_type, tenant_id: tenant_id, name: name, latitude: latitude, longitude: longitude, address_id: id, nexus_id: id)
      return self.hubs.where(hub_type: hub_type, tenant_id: tenant_id)
    else
      hubs
    end
  end

  def pretty_hub_type
    case address_type
    when "hub_train"
      "Train Hub"
    when "hub_ocean"
      "Port"
    else
      raise "Unknown Hub Type!"
    end
  end

  def city_country
    "#{city}, #{country.name}"
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
    hubs = Address.where(address_type: "nexus")
    distances = []
    hubs.each do |hub|
      distances << Geocoder::Calculations.distance_between([latitude, longitude], [hub.latitude, hub.longitude])
    end

    lowest_distance = distances.min
    hubs[distances.find_index(lowest_distance)]
  end

  def closest_address_with_distance
    nexuses = Nexus.all
    distances = nexuses.map do |nexus|
      Geocoder::Calculations.distance_between(
        [latitude, longitude],
        [nexus.latitude, nexus.longitude]
      )
    end
  end

  def closest_hubs
    hubs = Address.where(address_type: "nexus")
    distances = {}
    hubs.each_with_index do |hub, i|
      distances[i] = Geocoder::Calculations.distance_between([latitude, longitude], [hub.latitude, hub.longitude])
    end
    return final_result unless final_result.nil?
    keys.to_a.reverse_each.with_index do |name_i, _i|
      final_result = where(name_i => name_2).first

      break if final_result
    end

    final_result
  end

  def self.cascading_find_by_name(raw_name)
    name = raw_name.split.map(&:capitalize).join(' ')

    sanitize_zip_code!
    zip_code
  end

  def to_custom_hash
    custom_hash = { country: country.try(:name) }
    %i[
      id city street street_number zip_code
      geocoded_address latitude longitude
      address_type name
    ].each do |attribute|
      custom_hash[attribute] = self[attribute]
    end

    nil
  end

  private

  def self.address_params(raw_address_params)
    country = Country.geo_find_by_name(raw_address_params["country"])

    filtered_params = raw_address_params.try(:permit,
      :latitude, :longitude, :geocoded_address, :street,
      :street_number, :zip_code, :city) || raw_address_params

    filtered_params.to_h.merge(country: country)
  end

  def sanitize_zip_code!
    return if zip_code.nil?

    self.zip_code = zip_code.gsub(/[^a-zA-z\d]/, "")
  end
end
