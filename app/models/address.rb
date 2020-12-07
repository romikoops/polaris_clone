# frozen_string_literal: true

class Address < Legacy::Address
  has_many :contacts
  has_many :ports, foreign_key: :nexus_id
  has_many :ports
  has_one :hub
  has_many :routes
  has_many :stops, through: :hubs
  belongs_to :country, optional: true

  scope :nexus, -> { where(address_type: "nexus") }

  before_validation :sanitize_zip_code!

  # Geocoding
  geocoded_by :geocoded_address

  reverse_geocoded_by :latitude, :longitude do |address, results|
    if (geo = results.first)
      premise_data = geo.address_components.find do |address_component|
        address_component["types"] == ["premise"]
      end || {}
      address.premise = premise_data["long_name"]
      address.street_number = geo.street_number
      address.street = geo.route
      address.street_address = geo.street_number.to_s + " " + geo.route.to_s
      address.geocoded_address = geo.address
      address.city = geo.city
      address.zip_code = geo.postal_code
      address.country = Country.find_by(code: geo.country_code)
    end

    address
  end

  # Class methods
  def set_geocoded_address_from_fields!
    raw_address = "#{street} #{street_number}, #{premise}, #{zip_code} #{city}, #{country&.name}"
    self.geocoded_address = raw_address.gsub(/\s+/, " ").gsub(/\s+,/, ",").strip
      .gsub(/^,/, "").delete_suffix(",").strip.squeeze(",")
  end

  def geocode_from_address_fields!
    set_geocoded_address_from_fields!
    geocode
    save!
    self
  end

  def self.create_and_geocode(raw_address_params)
    address = Address.find_or_create_by(address_params(raw_address_params))
    address.geocode_from_address_fields! if address.geocoded_address.nil?
    address.reverse_geocode if address.zip_code.nil?
    address
  end

  def self.new_from_raw_params(raw_address_params)
    new(address_params(raw_address_params))
  end

  def self.create_from_raw_params!(raw_address_params)
    address = create!(address_params(raw_address_params))
    address.reverse_geocode if address.country.nil?
    address.save!
    address
  end

  def city_country
    "#{city}, #{country.name}"
  end

  def full_address
    part_one = [street, street_number].delete_if(&:blank?).join(" ")
    part_two = [zip_code, city, country.name].delete_if(&:blank?).join(", ")
    [part_one, part_two].delete_if(&:blank?).join(", ")
  end

  def lat_lng_string
    "#{latitude},#{longitude}"
  end

  def furthest_hubs(hubs)
    hubs.sort_by do |hub|
      hub.distance_to(self)
    end
  end

  def to_custom_hash
    custom_hash = {country: country.try(:name)}
    %i[
      id city street street_number zip_code
      geocoded_address latitude longitude
      address_type name
    ].each do |attribute|
      custom_hash[attribute] = self[attribute]
    end

    custom_hash
  end

  def get_zip_code
    reverse_geocode if zip_code.nil?

    sanitize_zip_code!
    zip_code
  end

  def self.address_params(raw_address_params)
    country = Country.geo_find_by_name(raw_address_params["country"])
    filtered_params = raw_address_params.try(:permit,
      :latitude, :longitude, :geocoded_address, :street,
      :street_number, :zip_code, :city) || raw_address_params

    filtered_params.to_h.merge(country: country)
  end

  private

  def sanitize_zip_code!
    return if zip_code.nil?

    self.zip_code = zip_code.gsub(/[^a-zA-z\d]/, "")
  end
end

# == Schema Information
#
# Table name: addresses
#
#  id               :bigint           not null, primary key
#  address_line_1   :string
#  address_line_2   :string
#  address_line_3   :string
#  city             :string
#  geocoded_address :string
#  latitude         :float
#  location_type    :string
#  longitude        :float
#  name             :string
#  photo            :string
#  point            :geometry         geometry, 0
#  premise          :string
#  province         :string
#  street           :string
#  street_address   :string
#  street_number    :string
#  zip_code         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  country_id       :integer
#  sandbox_id       :uuid
#
# Indexes
#
#  index_addresses_on_point       (point) USING gist
#  index_addresses_on_sandbox_id  (sandbox_id)
#
