module PricingTools
  include MongoTools
  def get_mongo_client 
    client = get_client
    return client
  end
  def get_user_price(client, pathKey, user)
    priceObj = get_item_fn(client, 'pathPricing', '_id', pathKey)
    if priceObj["#{user.id}"]
      priceKey = priceObj["#{user.id}"]
    else
      priceKey = priceObj["open"]
    end
    
    priceHash = get_item_fn(client, 'pricings', '_id', priceKey)
    
    return priceHash
  end

  def determine_lcl_price(client, cargo, pathKey, user, quantity)
        
    pricing = get_user_price(client, pathKey, user)

    
    totals = {"total" => {}}
    pricing["data"].each do |k, v|
      case v["rate_basis"]
      when "PER_ITEM"
        totals[k] ? totals[k]["value"] += v["rate"].to_i : totals[k] = {"value" => v["rate"].to_i, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_CBM"
        totals[k] ? totals[k]["value"] += v["rate"].to_i * cargo.volume : totals[k] = {"value" => v["rate"].to_i * cargo.volume, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_CBM_TON"
        ton = cargo.payload_in_tons * v["ton"]
        cbm = cargo.volume * v["cbm"]
        tmp = 0
        cbm > ton ? tmp = cbm : tmp = ton
        tmp > v["min"] ? res = tmp : res = v["min"]
        totals[k] ? totals[k]["value"] += res : totals[k] = {"value" => res, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_SHIPMENT"
        totals[k] ? totals[k]["value"] += v["rate"].to_i / quantity : totals[k] = {"value" => v["rate"].to_i / quantity, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      end
    end
    totals["total"] = {value: sum_and_convert_cargo(totals, "EUR"), currency: "EUR"}
    
    return totals
  end

  def determine_fcl_price(client, container, pathKey, user, quantity)
    pricing = get_user_price(client, pathKey, user)
    
    totals = {"total" => {}}
    pricing["data"].each do |k, v|
      if v["rate_basis"].include?('CONTAINER')
        totals[k] ? totals[k]["value"] += v["rate"].to_i : totals[k] = {"value" => v["rate"].to_i, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
        # totals[v["currency"]] ? totals[v["currency"]] += v["rate"].to_i : totals[v["currency"]] = v["rate"].to_i 
      end
    end
    totals["total"] = {value: sum_and_convert_cargo(totals, "EUR"), currency: "EUR"}
    return totals
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

  def get_route_pricings_array(route_id, tenant_id)
    client = get_client
    query = [{'tenant_id' => {"$eq" => tenant_id}}, {"route" => {"$eq" => route_id.to_i}}]
    resp = get_items_query_fn(client, 'pricings', query).to_a
    return resp
  end

  def get_user_pricings(user_id)
    resp = get_items('userPricings', '_id', "#{user_id}")
    return resp.first
  end

  def get_dedicated_hash(user_id, tenant_id)
    query = [{'tenant_id' => {"$eq" => tenant_id}}, {"#{user_id}" => {"$exists" => true}}]
    resp = get_items_query('pathPricing', query).to_a
    result = {}
    resp.each do |pr|
      result["#{pr["route"]}"] = true
    end
    return result
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

  def update_pricing(id, data)
    resp = update_item('pricings', {_id: id }, data)
    return resp
  end

  def get_route_pricings_hash(route_id)
    resp = get_items('pathPricing', 'route', route_id).to_a
    result = {}
    resp.each do |pr|
      result[pr["_id"]] = pr
    end
    return result
  end

  def get_hub_route_user_pricings(hub_route_id, user_id)
    query = [{'hub_route' => {"$eq" => hub_route_id}}, {"#{user_id}" => {"$exists" => true}}]
    resp = get_items_query('pathPricing', query)
    return resp.to_a
  end
end


