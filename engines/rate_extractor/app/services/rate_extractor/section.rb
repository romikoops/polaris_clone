# frozen_string_literal: true

module RateExtractor
  class Section
    attr_reader :path, :tenant

    def initialize(tenant:, path:, sandbox: nil)
      @tenant = tenant
      @path = path
      @sandbox = sandbox
    end

    def rates
      @rates ||= begin
        query = Rates::Section.none

        path_pairs.each do |(edge_point_a, edge_point_b)|
          query = rates_for_route_line_service(query, edge_point_a)
          query = rates_for_route_line_service(query, edge_point_b)
          query = query.or(rates_for_connections(edge_connections(edge_point_a, edge_point_b)))
        end

        query.where(tenant: tenant)
      end
    end

    private

    def path_pairs
      path.each_cons(2)
    end

    def edge_connections(edge_point_a, edge_point_b)
      inbound_connection = ::TenantRouting::Connection.where(
        inbound: nil, outbound: edge_point_a, tenant: tenant
      ).limit(1)
      mid_connection = ::TenantRouting::Connection.where(
        inbound_id: edge_point_a, outbound_id: edge_point_b, tenant: tenant
      ).limit(1)
      outbound_connection = ::TenantRouting::Connection.where(
        inbound_id: edge_point_b, outbound: nil, tenant: tenant
      ).limit(1)

      [inbound_connection, mid_connection, outbound_connection]
    end

    def rates_for_connections(connections)
      Rates::Section.where(target: connections)
    end

    def rates_for_route_line_service(rates, route_line_service)
      rates_by_route_line_service = Rates::Section.where(target: route_line_service)
      route = route_line_service.route

      rates.or(
        rates_by_route_line_service.where(
          location: route.origin,
          terminal: route.origin_terminal
        )
      ).or(
        rates_by_route_line_service.where(
          location: nil,
          terminal: nil
        )
      ).or(
        rates_by_route_line_service.where(
          location: route.destination,
          terminal: route.destination_terminal
        )
      )
    end
  end
end
