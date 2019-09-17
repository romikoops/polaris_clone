# frozen_string_literal: true

namespace :routing do
  task import_routes: :environment do
    routes = []
    missed_names = []
    blocked = {}
    mot_hash = { ocean: 1, air: 2, rail: 3, truck: 4, carriage: 5 }
    default_cargo_types = { lcl: false, fcl_reefer: false, fcl: false }
    Legacy::Itinerary.find_each do |itinerary|
      next if itinerary.tenant.nil?

      key = [itinerary.name, itinerary.mode_of_transport].join('-')
      time_factor, price_factor = case itinerary.mode_of_transport
                                  when 'ocean'
                                    [8, 2]
                                  when 'air'
                                    [1, 10]
                                  when 'truck'
                                    [7, 7]
                                  when 'rail'
                                    [10, 4]
                                  else
                                    [1, 10]
                                  end
      origin_hub = itinerary.first_stop&.hub
      dest_hub = itinerary.last_stop&.hub
      origin = Routing::Location.find_or_create_by(
        name: origin_hub.nexus.name,
        country_code: origin_hub.address&.country&.code
      )

      destination = Routing::Location.find_or_create_by(
        name: dest_hub.nexus.name,
        country_code: dest_hub.address&.country&.code
      )
      origin_terminal = Routing::Terminal.find_or_create_by(
        location_id: origin.id,
        mode_of_transport: mot_hash[origin_hub.hub_type.to_sym]
      )

      destination_terminal = Routing::Terminal.find_or_create_by(
        location_id: destination.id,
        mode_of_transport: mot_hash[dest_hub.hub_type.to_sym]
      )
      origin.update(center: origin_hub.point_wkt) unless origin.center
      destination.update(center: dest_hub.point_wkt) unless destination.center

      missed_names << origin_hub.nexus.name unless origin.present?
      missed_names << dest_hub.nexus.name unless destination.present?
      next unless origin.present? && destination.present?

      next if blocked[key].present?

      cargo_types = default_cargo_types.dup
      itinerary.pricings.map(&:cargo_class).uniq.each do |cc|
        if cc == 'lcl'
          cargo_types[:lcl] = true
        elsif cc.include?('_rf')
          cargo_types[:fcl_reefer] = true
        else
          cargo_types[:fcl] = true
        end
      end
      route = Routing::Route.find_or_create_by(
        origin_id: origin.id,
        destination_id: destination.id,
        origin_terminal_id: origin_terminal.id,
        destination_terminal_id: destination_terminal.id,
        mode_of_transport: itinerary.mode_of_transport.to_sym
      )

      route&.update(price_factor: price_factor, time_factor: time_factor)
      route&.update(cargo_types)

      blocked[key] = true
    end
    puts missed_names
    puts 'Itineraries parsed'
    puts 'Starting carriage'

    ::Legacy::Hub.find_each do |hub|
      hub_loc = Routing::Location.find_by(name: hub.nexus.name, country_code: hub.address&.country&.code.downcase)
      mot_enum = mot_hash[hub.hub_type.to_sym]
      next unless hub_loc
      
      hub_terminal = Routing::Terminal.find_or_create_by(location_id: hub_loc.id, mode_of_transport: mot_enum)
      truckings = hub.truckings
      trucking_locations = Trucking::Location.where(id: hub.truckings.pluck(:location_id).uniq)
      locations = Locations::Location.where(id: trucking_locations.pluck(:location_id).uniq)
      Routing::Location.where(name: locations.pluck(:name).uniq, country_code: hub.address.country.code.downcase).where.not(bounds: nil).each do |trucking_location|
        [
          { origin_id: hub_loc.id, origin_terminal_id: hub_terminal.id, destination_id: trucking_location.id },
          { origin_id: trucking_location.id, destination_id: hub_loc.id, destination_terminal_id: hub_terminal.id }
        ].each do |direction|
          Routing::Route.find_or_create_by({
            mode_of_transport: :carriage,
            time_factor: 2,
            price_factor: 4,
            allowed_cargo: 3
          }.merge(direction))
        end
      end
    end
  end
end
