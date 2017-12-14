module PricingTools
  include MongoTools
  def get_user_price(pathKey, user)
    priceObj = get_item('pathPricing', '_id', pathKey)
    if priceObj["#{user.id}"]
      priceKey = priceObj["#{user.id}"]
    else
      priceKey = priceObj["open"]
    end
    
    priceHash = get_item('pricings', '_id', priceKey)
    
    return priceHash
  end

  def get_tenant_pricings(tenant_id)
    resp = get_items('pricings', 'tenant_id', tenant_id)
    return resp.to_a
  end

  def get_tenant_pricings_hash(tenant_id)
    resp = get_items('pricings', 'tenant_id', tenant_id).to_a
    result = {}
    resp.each do |pr|
      result[pr["_id"]] = pr
    end
    return result
  end

  def get_user_pricings(user_id)
    resp = get_items('userPricings', '_id', "#{user_id}")
    return resp.first
  end

  def get_tenant_path_pricings(tenant_id)
    resp = get_items('pathPricing', 'tenant_id', tenant_id)
    return resp.to_a
  end

  def get_hub_route_pricings(hub_route_id)
    resp = get_items('pathPricing', 'hub_route', hub_route_id)
    return resp.to_a
  end

  def get_route_pricings(route_id)
    resp = get_items('pathPricing', 'route', route_id)
    return resp.to_a
  end

  def get_hub_route_user_pricings(hub_route_id, user_id)
    query = [{'hub_route' => {"$eq" => hub_route_id}}, {"#{user_id}" => {"$exists" => true}}]
    resp = get_items_query('pathPricing', query)
    return resp.to_a
  end
end
