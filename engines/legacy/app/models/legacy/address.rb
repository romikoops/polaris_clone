# frozen_string_literal: true

module Legacy
  class Address < ApplicationRecord
    self.table_name = 'addresses'
    has_one :legacy_hub
    belongs_to :country, class_name: 'Legacy::Country', optional: true
    geocoded_by :geocoded_address

    before_validation :sanitize_zip_code!
    after_validation :reverse_geocode, if: proc { |address| address.country.nil? }

    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    reverse_geocoded_by :latitude, :longitude do |address, results|
      if geo = results.first
        premise_data = geo.address_components.find do |address_component|
          address_component['types'] == ['premise']
        end || {}
        address.premise          = premise_data['long_name']
        address.street_number    = geo.street_number
        address.street           = geo.route
        address.street_address   = geo.street_number.to_s + ' ' + geo.route.to_s
        address.geocoded_address = geo.address
        address.city             = geo.city
        address.zip_code         = geo.postal_code

        address.country          = Country.find_by(code: geo.country_code)
      end

      address
    end

    def full_address
      part_one = [street, street_number].delete_if(&:blank?).join(' ')
      part_two = [zip_code, city, country.name].delete_if(&:blank?).join(', ')
      [part_one, part_two].delete_if(&:blank?).join(', ')
    end

    def get_zip_code
      reverse_geocode if zip_code.nil?

      sanitize_zip_code!
      zip_code
    end

    def self.new_from_raw_params(raw_address_params)
      new(address_params(raw_address_params))
    end

    def self.geocoded_address(user_input, sandbox = nil)
      address = Address.new(geocoded_address: user_input)
      address.sandbox = sandbox
      address.geocode
      address.reverse_geocode
      address.save!
      address
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
      keys = %i( id city street street_number zip_code geocoded_address latitude longitude location_type name)
      slice(keys).merge(country: country&.name).symbolize_keys
    end

    def self.address_params(raw_address_params)
      country = Legacy::Country.geo_find_by_name(raw_address_params['country'])
      filtered_params = raw_address_params.try(:permit,
                                               :latitude, :longitude, :geocoded_address, :street,
                                               :street_number, :zip_code, :city) || raw_address_params
      filtered_params.to_h.merge(country: country)
    end

    def sanitize_zip_code!
      return if zip_code.nil?

      self.zip_code = zip_code.gsub(/[^a-zA-z\d]/, '')
    end

    def set_geocoded_address_from_fields!
      raw_address = "#{street} #{street_number}, #{premise}, #{zip_code} #{city}, #{country&.name}"
      self.geocoded_address = raw_address.gsub(/\s+/, ' ').gsub(/\s+,/, ',').strip
                                         .gsub(/^,/, '').gsub(/,\z/, '').strip
                                         .gsub(/,+/, ',')
    end
  end
end

# == Schema Information
#
# Table name: addresses
#
#  id               :bigint           not null, primary key
#  city             :string
#  geocoded_address :string
#  latitude         :float
#  location_type    :string
#  longitude        :float
#  name             :string
#  photo            :string
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
#  index_addresses_on_sandbox_id  (sandbox_id)
#
