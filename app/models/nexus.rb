# frozen_string_literal: true

class Nexus < Legacy::Nexus
  has_many :hubs
  has_many :shipments
  belongs_to :organization, class_name: "Organizations::Organization"
  belongs_to :country, class_name: "Legacy::Country"
  geocoded_by :geocoded_address

  reverse_geocoded_by :latitude, :longitude do |location, results|
    if (geo = results.first)
      location.country = Country.find_by(code: geo.country_code)
    end

    location
  end

  def hubs_by_type(hub_type, organization_id)
    hubs.where(hub_type: hub_type, organization_id: organization_id)
  end

  def to_custom_hash
    custom_hash = {country: country.try(:name)}
    %i[
      id latitude longitude name
    ].each do |attribute|
      custom_hash[attribute] = self[attribute]
    end

    custom_hash
  end

  def self.update_country
    Nexus.all.find_each do |nexus|
      old_nexus = Address.find_by("name ILIKE ? AND location_type = ?", nexus.name, "nexus")
      nexus.country_id = old_nexus.country_id
      nexus.save!
    end
  end

  def city_country
    "#{name}, #{country.name}"
  end

  def self.from_short_name(input, organization_id)
    city, country_name = *input.split(" ,")

    country = Country.geo_find_by_name(country_name)

    address = Nexus.find_by(name: city, country: country, organization_id: organization_id)
    return address unless address.nil?

    temp_address = Address.new(geocoded_address: input)
    temp_address.geocode
    temp_address.reverse_geocode
    nexus = Nexus.find_by(name: city, country: country, organization_id: organization_id)
    return nexus unless nexus.nil?

    country_to_save = country || temp_address.country
    Nexus.create!(
      name: city,
      latitude: temp_address.latitude,
      longitude: temp_address.longitude,
      photo: "",
      country_id: country_to_save.id,
      organization_id: organization_id
    )
  end
end

# == Schema Information
#
# Table name: nexuses
#
#  id              :bigint           not null, primary key
#  latitude        :float
#  locode          :string
#  longitude       :float
#  name            :string
#  photo           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  country_id      :integer
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_nexuses_on_organization_id  (organization_id)
#  index_nexuses_on_sandbox_id       (sandbox_id)
#  index_nexuses_on_tenant_id        (tenant_id)
#  nexus_upsert                      (locode,organization_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
