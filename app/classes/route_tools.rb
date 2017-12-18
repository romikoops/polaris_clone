module RouteTools
  include MongoTools
  def get_routes_with_dedicated_pricings(user_id, tenant_id)
    query = [{'tenant_id' => {"$eq" => tenant_id}}, {"#{user_id}" => {"$exists" => true}}]
    resp = get_items_query('pathPricing', query)
    return resp.map { |pr| pr["route"] }.uniq
  end
end
