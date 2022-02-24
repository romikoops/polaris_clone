# frozen_string_literal: true

module Helmsman
  class Validator
    attr_reader :route_line_services, :carriage_ids, :tenant_connections

    def initialize(organization_id:, paths:, user:)
      @organization = Organizations::Organization.find(organization_id)
      federated_targets = Federation::Members.new(organization: @organization).list
      route_targets = OrganizationManager::HierarchyService.new(target: user, organization: @organization).fetch
      @visibilities = TenantRouting::Visibility.where(target: route_targets)
      @tenant_connections = TenantRouting::Connection.where(organization_id: federated_targets)
      @route_line_services = Routing::RouteLineService.where(route_id: paths.flatten)
      @carriage_ids = Routing::RouteLineService.joins(:route)
        .where(
          routing_routes: {
            mode_of_transport: Routing::Route.mode_of_transports[:carriage]
          }
        ).ids
      unless @visibilities.empty?
        @tenant_connections = tenant_connections.where(id: @visibilities.select(:connection_id))
      end
      @paths = paths
    end

    def filter
      expand_paths.each_with_object([]) do |route_line_service_ids, accumulator|
        matches = []
        adj_route_ids = route_line_service_ids.map { |route_line_service_id|
          carriage_ids.include?(route_line_service_id) ? nil : route_line_service_id
        }
        # Replaces carriage route line service ids with nil for TenantConnection validation
        grouped_route_line_services = adj_route_ids.slice_when { |x, y| x.nil? || y.nil? }.to_a

        # Breaks array into consecutive pairs for the TenantConnection checker
        freight_group_index = grouped_route_line_services.index { |group| group.compact.present? }
        if grouped_route_line_services[freight_group_index].length == 1
          # If there is only one freight route, we double it up as inbound and outbound
          grouped_route_line_services[freight_group_index] =
            [grouped_route_line_services[freight_group_index].first] * 2
        end

        # Take each consecutive adjusted pair (ie. with nil values) and run valid?
        grouped_route_line_services.flatten.each_cons(2).each do |route_arr|
          matches << valid?(route_arr)
        end
        # Reject if any of the section fails the valid? call
        next unless matches.all?

        accumulator << route_line_service_ids
      end
    end

    def expand_paths
      paths.flat_map do |route_id_arr|
        values = route_id_arr.map { |route_id|
          route_line_services.where(route_id: route_id).ids
        }

        values.shift.product(*values)
      end
    end

    def valid?(route_ids)
      # Checks to see that a TenantConnection exists and that the RouteLineService has Rates
      return false if route_ids.empty?

      tenant_connections.exists?(inbound_id: route_ids.first, outbound_id: route_ids.last)
    end

    attr_reader :paths
  end

  # Expected format of routes:
  # An array of arrays containg the route ids for each section of the journey: precarriage, freight, on carriage
  # (potentially more with transshipments). Each route id is checked against the tenants TenantRouting::Connection
  # objects and results are divided into valid (all ids return a TenantRouting::Connection) and partial
  # (some not all have a TenantRouting::Connection)
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
