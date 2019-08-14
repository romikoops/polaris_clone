# frozen_string_literal: true

namespace :tenant_routing do
  task import: :environment do
    routes = []
    Routing::Route.where.not(mode_of_transport: :carriage).find_each do |route|
      Legacy::Itinerary.where(
        sandbox_id: nil,
        name: [route.origin.name, route.destination.name].join(' - '),
        mode_of_transport: route.mode_of_transport
      ).each do |it|
        next if it.tenant.nil?

        routes << {
          inbound_id: route.id,
          outbound_id: route.id,
          tenant_id: it.tenant.tenants_tenant.id
        }

        if Trucking::Trucking.exists?(tenant_id: it.tenant_id, hub_id: itinerary.first_stop.hub_id, carriage: 'pre')
          routes << {
            inbound_id: nil,
            outbound_id: route.id,
            tenant_id: it.tenant.tenants_tenant.id
          }
        end
        if Trucking::Trucking.exists?(tenant_id: it.tenant_id, hub_id: itinerary.last_stop.hub_id, carriage: 'on')
          routes << {
            outbound_id: nil,
            inbound_id: route.id,
            tenant_id: it.tenant.tenants_tenant.id
          }
        end
      end
    end
    hamburgs = Hub.where("name ILIKE ?", 'Hamburg%')
    routing_hamburg = Routing::Location.find_by(locode: 'DEHAM')
    blocked = {}
    Routing::Location.where(country_code: 'de', locode: nil).each do |tl|
      hamburgs.each do |hamburg|
        trucking = Trucking::Trucking.where(hub: hamburg).joins(:location).where(trucking_locations: { zipcode: tl.name}).first
        next unless trucking.present?

        route = Routing::Route.find_by(
          origin_id: trucking.carriage == 'pre' ? tl : routing_hamburg,
          destination_id: trucking.carriage == 'pre' ? routing_hamburg : tl
        )
        key = [route.id, hamburg.tenant.tenants_tenant.id].join('-')
        next if blocked[key].present?

        new_route = {
          route_id: route.id,
          tenant_id: hamburg.tenant.tenants_tenant.id,
          time_factor: route.time_factor,
          price_factor: route.price_factor
        }

        routes << new_route
      end
    end

    TenantRouting::Connection.import(routes)
  end
end

