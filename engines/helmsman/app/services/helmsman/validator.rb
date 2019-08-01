module Helmsman
  class Validator
    def initialize(tenant_id: , routes:)
      @tenant = Tenants::Tenant.find(tenant_id)
      @tenant_routes = TenantRouting::Route.where(tenant_id: tenant_id)
      @routes = routes
    end

    def perform
      @routes.each_with_object(Hash.new {|h,k| h[k] = []}) do |route_ids, hash|
        matches = @tenant_routes.where(route_id: route_ids).ids
        next if matches.empty?

        key = matches.length == route_ids.length ? :valid : :partial
        hash[key] << matches
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