# frozen_string_literal: true

module Helmsman
  class Validator
    def initialize(tenant_id:, routes:, user:)
      @tenant = Tenants::Tenant.find(tenant_id)
      route_targets = Tenants::HierarchyService.new(target: user, tenant: @tenant).fetch
      @visibilities = TenantRouting::Visibility.where(target: route_targets)
      @tenant_connection = TenantRouting::Connection.where(tenant_id: tenant_id)

      @tenant_connection = @tenant_connection.where(id: @visibilities.pluck(:connection_id)) unless @visibilities.empty?
      @routes = routes
    end

    def filter
      @routes.each_with_object([]) do |route_ids, arr|
        carriage_routes = Routing::Route.where(id: route_ids, mode_of_transport: :carriage)
        matches = []
        adj_route_ids = route_ids.map { |id| carriage_routes.ids.include?(id) ? nil : id }

        grouped_routes = adj_route_ids.slice_when { |x, y| x.nil? || y.nil? }.to_a
        freight_group_index = grouped_routes.index { |g_arr| g_arr.compact.present? }
        if grouped_routes[freight_group_index].length == 1
          grouped_routes[freight_group_index] = [
            grouped_routes[freight_group_index].first,
            grouped_routes[freight_group_index].first
          ]
        end

        grouped_routes.flatten.each_cons(2).each do |route_arr|
          matches << @tenant_connection.exists?(inbound: route_arr.first, outbound: route_arr.last)
        end
        next if matches.none?(&:present?)

        arr << route_ids
      end
    end

    attr_reader :routes
  end

  # Expected format of routes:
  # An array of arrays containg the route ids for each section of the journey: precarriage, freight, on carriage
  # (potentially more with transshipments). Each route id is checked against the tenants TenantRouting::Route objects and
  # results are divided into valid (all ids return a TenantRouting::Route) and partial (some not all have a TenantRouting::Route)
  # Door to Door example (3 routes)
  # routes = [
  #   [ precarriage_route_id, freight_route_id, oncarriage_route_id ]
  # ]
  # Port to Port example (1 route)
  # routes = [
  #   [ freight_route_id ]
  # ]
  # Door to Port example (2 routes)
  # routes = [
  #   [ precarriage_route_id, freight_route_id ]
  # ]
  # Port to Door example (2 routes)
  # routes = [
  #   [ freight_route_id, oncarriage_route_id ]
  # ]
end
