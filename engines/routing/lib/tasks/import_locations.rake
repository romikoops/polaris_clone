# frozen_string_literal: true

namespace :routing do
  task import_locations: :environment do
    hub_locations = []
   
    ::Legacy::Hub.find_each do |hub|
      next if Routing::Location.exists?(name: hub.nexus.name, country_code: hub.address.country.code.downcase)
      next if [hub.address.longitude, hub.address.latitude].any?(&:nil?)
      lng_lat = [hub.address.longitude, hub.address.latitude].join(' ')
      next unless lng_lat.present?

    
      hub_locations << {
        name: hub.nexus.name,
        locode: '',
        country_code: hub.address.country.code.downcase,
        center: "POINT (#{lng_lat})"
      }
    end

    Routing::Location.import(hub_locations)
    mot_hash = { ocean: 1, air: 2, rail: 3, truck: 4, carriage: 5 }
    terminal_locations = []
    ::Legacy::Hub.find_each do |hub|
      mot_enum = mot_hash[hub.hub_type.to_sym]
      hub_loc = Routing::Location.find_by(name: hub.nexus.name, country_code: hub.address.country.code.downcase)
      next if hub_loc.nil?
      next if Routing::Terminal.exists?(location_id: hub_loc.id, mode_of_transport: mot_enum)
      next if [hub.address.longitude, hub.address.latitude].any?(&:nil?)
      lng_lat = [hub.address.longitude, hub.address.latitude].join(' ')
      next unless lng_lat.present?

      terminal_locations << {
        location_id: hub_loc.id,
        mode_of_transport: mot_enum,
        center: "POINT (#{lng_lat})"
      }
     
    end

    Routing::Terminal.import(terminal_locations)

    trucking_locations = []
    trucking_location_ids = Trucking::Location.where.not(location_id: nil).pluck(:location_id)
    Locations::Location.where(id: trucking_location_ids).where.not(bounds: nil).each do |location|
      trucking_locations << {
        name: location.name,
        country_code: location.country_code.downcase,
        center: location.bounds.centroid,
        bounds: location.bounds
      }
    end
    Routing::Location.import(trucking_locations)
  end
end
