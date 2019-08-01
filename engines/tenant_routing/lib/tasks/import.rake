# frozen_string_literal: true

namespace :tenant_routing do
  task import: :environment do
    routes = []
    Routing::Route.find_each do |route|
      Legacy::Itinerary.where(sandbox_id: nil, name: [route.origin.name, route.destination.name].join(' - ')).each do |it|
        next if it.tenant.nil?

        new_route = {
          route_id: route.id,
          tenant_id: it.tenant.tenants_tenant.id,
          time_factor: route.time_factor,
          price_factor: route.price_factor
        }
        routes << new_route
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

    TenantRouting::Route.import(routes)
  end
end

