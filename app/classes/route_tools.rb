module RouteTools
  include MongoTools
  def get_routes_with_dedicated_pricings(user_id, tenant_id)
    query = [
    	{ "tenant_id"  => {"$eq" => tenant_id} }, 
    	{ "#{user_id}" => {"$exists" => true} }
    ]
    hub_route_pricings = get_items_query('hubRoutePricings', query)
    return hub_route_pricings.map { |hub_route_pricing| hub_route_pricing["route"] }.uniq
  end

  def get_hub_route_pricings(route_id, transport_category_ids)
    query = [ 
      { "route_id" => { "$eq" => route_id } }, 
      { "transport_category_id" => { "$in" => transport_category_ids } }
    ]
    hub_route_pricings = get_items_query('hubRoutePricings', query)
    return hub_route_pricings.to_a
  end

  def get_route_option(route)
		query = [
      { 
        "$match" => { "id" => route.tenant.id } 
      },
      { 
        "$project" => {
          "data" => { 
            "$filter" => {
              "input" => "$data",
              "as"    => "route",
              "cond"  => { "$eq" => ["$$route.id", route.id]},
            }
          }
        }
      }
    ]
		return get_items_aggregate("routeOptions", query)
  end

  def get_scoped_routes(tenant_id, mot_scope_ids)
		query = [
      { 
        "$match" => { "id" => tenant_id } 
      },
      { 
        "$project" => {
          "data" => { 
            "$filter" => {
              "input" => "$data",
              "as"    => "route",
              "cond"  => { "$in" => ["$$route.mot_scope_id", mot_scope_ids]},
            }
          }
        }
      }
    ]
		return get_items_aggregate("routeOptions", query)
  end

  def update_route_option(route)
  # 	return if get_route_option(route).empty?

  # 	update = route.attributes.each_with_object({}) do |(k, v), h|
  # 		h["data.$.#{k}"] = v
  # 	end

  # 	key = { "$and" => [
	 #  		{ "id" => { "$eq" => route.tenant.id } },
	 #  		{ "data.id" => { "$eq" => route.id } }
 	# 		]
  # 	}
		# update_item('routeOptions', key, update)
  end
end
