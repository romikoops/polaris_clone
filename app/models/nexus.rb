# frozen_string_literal: true

class Nexus < ApplicationRecord
  has_many :hubs
  has_many :shipments
  belongs_to :tenant
  belongs_to :country
  geocoded_by :geocoded_address

  reverse_geocoded_by :latitude, :longitude do |location, results|
    if geo = results.first
      location.country = Country.find_by(code: geo.country_code)
    end

    location
  end

  def hubs_by_type(hub_type, tenant_id)
    hubs.where(hub_type: hub_type, tenant_id: tenant_id)
  end

  def to_custom_hash
    custom_hash = { country: country.try(:name) }
    %i(
      id latitude longitude name
    ).each do |attribute|
      custom_hash[attribute] = self[attribute]
    end

    custom_hash
  end

  def self.migrate_hubs_from_location
    hub_type_name = {
      'ocean' => 'Port',
      'air'   => 'Airport',
      'rail'  => 'Railyard',
      'truck' => 'Depot'
    }

    hubs = Hub.all
    hubs.each do |hub|
      next if hub.nexus.is_a? Nexus
      old_nexus = Address.find_by(id: hub.nexus_id)
      unless old_nexus
        nexus_name = hub.name.gsub(" #{hub_type_name[hub.hub_type]}", '')
        old_nexus = Address.where('name ILIKE ? AND location_type = ?', nexus_name, 'nexus').first
      end
      new_nexus = Nexus.find_by(name: old_nexus.name, tenant_id: hub.tenant_id)
      new_nexus ||= Nexus.create!(
        name:       old_nexus.name,
        latitude:   old_nexus.latitude,
        longitude:  old_nexus.longitude,
        photo:      old_nexus.photo,
        country_id: old_nexus.country_id,
        tenant_id:  hub.tenant_id
      )
      hub.nexus_id = new_nexus.id
      hub.save!
    end
  end

  def self.migrate_shipments_from_location
    hub_type_name = {
      'ocean' => 'Port',
      'air'   => 'Airport',
      'rail'  => 'Railyard',
      'truck' => 'Depot'
    }

    shipments = Shipment.all
    shipments.each do |shipment|
      next if shipment.origin_nexus.is_a?(Nexus) && shipment.destination_nexus.is_a?(Nexus)
      %w(origin destination).each do |dir|
        old_nexus = Address.find_by(id: shipment["#{dir}_nexus_id"])
        unless old_nexus
          nexus_name = shipment["#{dir}_hub"].name.gsub(" #{shipment_type_name[shipment.shipment_type]}", '')
          old_nexus = Address.where('name ILIKE ? AND location_type = ?', nexus_name, 'nexus').first
        end
        new_nexus = Nexus.find_by(name: old_nexus.name, tenant_id: shipment.tenant_id)
        new_nexus ||= Nexus.create!(
          name:       old_nexus.name,
          latitude:   old_nexus.latitude,
          longitude:  old_nexus.longitude,
          photo:      old_nexus.photo,
          country_id: old_nexus.country_id,
          tenant_id:  shipment.tenant_id
        )
        shipment["#{dir}_nexus_id"] = new_nexus.id
      end

      shipment.save!
    end
  end

  def self.update_country
    Nexus.all.each do |nexus|
      old_nexus = Address.where('name ILIKE ? AND location_type = ?', nexus.name, 'nexus').first
      nexus.country_id = old_nexus.country_id
      nexus.save!
    end
  end

  def city_country
    "#{name}, #{country.name}"
  end

  def self.from_short_name(input, tenant_id)
    city, country_name = *input.split(' ,')

    country = Country.geo_find_by_name(country_name)

    address = Nexus.find_by(name: city, country: country, tenant_id: tenant_id)
    return address unless address.nil?

    temp_address = Address.new(geocoded_address: input)
    temp_address.geocode
    temp_address.reverse_geocode
    nexus = Nexus.find_by(name: city, country: country, tenant_id: tenant_id)
    return nexus unless nexus.nil?
    country_to_save = country || temp_address.country
    nexus = Nexus.create!(
      name:       city,
      latitude:   temp_address.latitude,
      longitude:  temp_address.longitude,
      photo:      '',
      country_id: country_to_save.id,
      tenant_id:  tenant_id
    )

    nexus
  end
end
